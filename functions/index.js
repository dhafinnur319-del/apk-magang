const { onRequest } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const { logger } = require("firebase-functions");

admin.initializeApp();
const db = admin.firestore();

// ============================================================
// TOKEN RAHASIA — ganti dengan string acak panjang Anda
// Simpan sama persis di cron-job.org nanti.
// ============================================================
const CRON_SECRET = "alfa-bapenda-2026-xK9mP3qR7tY2wN5vB8cD4fG6hJ1sL0aZ";

exports.scheduledAlfaCheck = onRequest(
  {
    region: "asia-southeast2",
    cors: false,
    timeoutSeconds: 300,
    memory: "256MiB",
  },
  async (req, res) => {
    // ---------- 1. PROTEKSI BEARER TOKEN ----------
    const authHeader = req.headers["authorization"] || "";
    if (authHeader !== `Bearer ${CRON_SECRET}`) {
      logger.warn("Unauthorized access attempt", {
        ip: req.ip,
        headers: req.headers,
      });
      return res.status(401).send("Unauthorized");
    }

    // ---------- 2. TENTUKAN TANGGAL ----------
    const today = getTodayDate();
    const dayOfWeek = getDayOfWeekWIB();

    logger.info(`[AlfaCheck] Mulai. Tanggal: ${today}, Hari: ${dayOfWeek}`);

    // ---------- 3. CEK HARI KERJA ----------
    if (dayOfWeek === 0 || dayOfWeek === 6) {
      logger.info(`[AlfaCheck] Weekend. Skip.`);
      return res.status(200).send("Weekend, skip.");
    }

    if (await checkHoliday(today)) {
      logger.info(`[AlfaCheck] Libur nasional. Skip.`);
      return res.status(200).send("Libur nasional, skip.");
    }

    // ---------- 4. AMBIL SEMUA PESERTA ----------
    const usersSnap = await db
      .collection("users")
      .where("role", "==", "peserta")
      .get();

    if (usersSnap.empty) {
      logger.info(`[AlfaCheck] Tidak ada peserta.`);
      return res.status(200).send("Tidak ada peserta.");
    }

    logger.info(`[AlfaCheck] Total peserta: ${usersSnap.size}`);

    // ---------- 5. LOOP PESERTA ----------
    let alfaCount = 0;
    let sudahAbsen = 0;
    let sedangIzin = 0;
    const batch = db.batch();

    for (const userDoc of usersSnap.docs) {
      const user = userDoc.data();
      const userId = userDoc.id;
      const nama = user.nama || "";

      if (!nama) {
        logger.warn(`[AlfaCheck] User ${userId} tidak punya nama. Skip.`);
        continue;
      }

      // 5a. Cek absensi hari ini
      const absensiSnap = await db
        .collection("absensi")
        .where("user_id", "==", userId)
        .where("tanggal", "==", today)
        .get();

      if (!absensiSnap.empty) {
        sudahAbsen++;
        continue;
      }

      // 5b. Cek izin/sakit disetujui
      const izinSnap = await db
        .collection("izin")
        .where("user_id", "==", userId)
        .where("tanggal", "==", today)
        .where("status", "==", "Disetujui")
        .get();

      if (!izinSnap.empty) {
        sedangIzin++;
        continue;
      }

      // 5c. Tandai Alfa
      const alfaRef = db.collection("absensi").doc();
      batch.set(alfaRef, {
        user_id: userId,
        nama: nama,
        tanggal: today,
        jam_masuk: null,
        jam_pulang: null,
        status: "Alfa",
        latitude: null,
        longitude: null,
        foto_masuk: null,
        created_at: admin.firestore.FieldValue.serverTimestamp(),
        generated_by: "system_alfa_check",
      });

      alfaCount++;
      logger.info(`[AlfaCheck] Alfa: ${nama}`);
    }

    // ---------- 6. COMMIT ----------
    if (alfaCount > 0) {
      await batch.commit();
    }

    const summary = `Selesai. Alfa: ${alfaCount}, Sudah absen: ${sudahAbsen}, Izin/Sakit: ${sedangIzin}`;
    logger.info(`[AlfaCheck] ${summary}`);
    return res.status(200).send(summary);
  }
);

// ============================================================
// HELPER
// ============================================================

function getTodayDate() {
  const now = new Date(
    new Date().toLocaleString("en-US", { timeZone: "Asia/Jakarta" })
  );
  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, "0");
  const day = String(now.getDate()).padStart(2, "0");
  return `${year}-${month}-${day}`;
}

function getDayOfWeekWIB() {
  const now = new Date(
    new Date().toLocaleString("en-US", { timeZone: "Asia/Jakarta" })
  );
  return now.getDay();
}

async function checkHoliday(dateStr) {
  const holidays = [
    "2026-01-01",
    "2026-03-19",
    "2026-03-20",
    "2026-05-01",
    "2026-05-14",
    "2026-06-01",
    "2026-08-17",
    "2026-12-25",
  ];
  return holidays.includes(dateStr);
}