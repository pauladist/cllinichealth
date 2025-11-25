// functions/index.js

const { onSchedule } = require("firebase-functions/v2/scheduler");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { logger } = require("firebase-functions");

const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

//
// ─────────────────────────────────────────────────────────────
//   1) RECORDATORIO 10 MIN ANTES DEL TURNO (FCM)
// ─────────────────────────────────────────────────────────────
//

//
// ─────────────────────────────────────────────────────────────
//   1) RECORDATORIO 10 MIN ANTES DEL TURNO (FCM)
// ─────────────────────────────────────────────────────────────
//
exports.sendAppointmentReminder = onSchedule(
  {
    schedule: "every 1 minutes",
    timeZone: "America/Argentina/Buenos_Aires",
    region: "us-central1",
  },
  async () => {
    try {
      const db = admin.firestore();
      const now = new Date();
      const tenMinutesFromNow = new Date(now.getTime() + 10 * 60 * 1000);

      logger.info("Buscando turnos entre:", now, "y", tenMinutesFromNow);

      // 👉 Solo turnos dentro de la ventana y que NO hayan sido notificados
      const apptsSnap = await db
        .collection("appointments")
        .where("dateTime", ">=", now)
        .where("dateTime", "<=", tenMinutesFromNow)
        .where("reminderSent", "==", false)
        .get();

      if (apptsSnap.empty) {
        logger.info("No hay turnos dentro de los próximos 10 minutos.");
        return;
      }

      const deviceSnap = await db.collection("devices").doc("doctor").get();
      if (!deviceSnap.exists) {
        logger.error("No existe devices/doctor");
        return;
      }

      const token = deviceSnap.get("token");
      if (!token) {
        logger.error("devices/doctor no tiene token");
        return;
      }

      for (const doc of apptsSnap.docs) {
        const appt = doc.data();
        const patientId = appt.patientId || "Paciente";
        const motivo = appt.motivo || "Consulta";
        const d = appt.dateTime.toDate();

        // ⏰ Formatear hora en horario de Argentina
        const timeStr = d.toLocaleTimeString("es-AR", {
          timeZone: "America/Argentina/Buenos_Aires",
          hour: "2-digit",
          minute: "2-digit",
        });

        const title = "Turno en 10 minutos";
        const body = `Tenés un turno (${motivo}) con el paciente ${patientId} a las ${timeStr}`;

        const message = {
          token,
          notification: { title, body },
          android: { priority: "high" },
        };

        try {
          await admin.messaging().send(message);
          logger.info("📩 Recordatorio enviado:", doc.id);
        } catch (err) {
          logger.error("❌ Error enviando push:", err);
        }

        // Guardar registro de notificación (MISMA colección que email, NO rompe nada)
        await db.collection("notifications").add({
          doctorId: "doctor",
          appointmentId: doc.id,
          title,
          body,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          expireAt: admin.firestore.Timestamp.fromDate(
            new Date(Date.now() + 24 * 60 * 60 * 1000)
          ),
          read: false,
          type: "appointment-reminder",
        });

        //  Marcar que ya fue notificado (para no repetir por minuto)
        await doc.ref.update({
          reminderSent: true,
        });
      }

      return;
    } catch (err) {
      logger.error(" Error general en sendAppointmentReminder:", err);
    }
  }
);






//
// ─────────────────────────────────────────────────────────────
//   2) ENVÍO DE MAIL AL CREAR CITA (CON QR = appointmentId)
// ─────────────────────────────────────────────────────────────
//

// CONFIGURACIÓN DEL CORREO
// ▸ Usá una cuenta Gmail con "App Password" (NO la contraseña común)

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "supervisorgeobuild@gmail.com",
    pass: "kixkzykfzzmmgpsk",
  },
});

// SE ACTIVA AUTOMÁTICAMENTE cuando se crea una cita
exports.sendAppointmentEmailOnCreate = onDocumentCreated(
  "appointments/{appointmentId}",
  async (event) => {
    const snap = event.data;
    if (!snap) return;

    const apptId = snap.id;
    const appt = snap.data();
    const db = admin.firestore();

    logger.info("📧 Preparando email para cita:", apptId);

    // 1) Buscar paciente
    const patientSnap = await db
      .collection("patients")
      .doc(appt.patientId)
      .get();

    if (!patientSnap.exists) {
      logger.error("Paciente no encontrado:", appt.patientId);
      return;
    }

    const patient = patientSnap.data();
    const email = patient.email;

    if (!email) {
      logger.error("⚠ El paciente no tiene email:", appt.patientId);
      return;
    }

        // 2) Formatear fecha/hora del turno en horario de Argentina
        const d = appt.dateTime.toDate();

        const dateStr = d.toLocaleDateString("es-AR", {
          timeZone: "America/Argentina/Buenos_Aires",
        });

        const timeStr = d.toLocaleTimeString("es-AR", {
          timeZone: "America/Argentina/Buenos_Aires",
          hour: "2-digit",
          minute: "2-digit",
        });


    const motivo = appt.motivo || "Consulta médica";

    const qrData = apptId;
  // URL del QR usando la API de goqr
    const qrUrl = `https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${encodeURIComponent(qrData)}`;

    // 3) Contenido del email — ACÁ EDITÁS EL TEXTO CUANDO QUIERAS
    const subject = `Tu turno médico - ${dateStr} ${timeStr}`;

      const htmlBody = `
        <p>Hola <b>${patient.nombre} ${patient.apellido}</b>,</p>

        <p>Tu turno fue registrado correctamente. Estos son los detalles:</p>

        <ul>
          <li><b>Fecha:</b> ${dateStr}</li>
          <li><b>Hora:</b> ${timeStr}</li>
          <li><b>Motivo:</b> ${motivo}</li>
        </ul>

        <p>Cuando llegues a la clínica, mostrá este código QR para registrar tu asistencia:</p>

        <p style="text-align:center;">
          <img
            src="${qrUrl}"
            alt="QR de tu turno"
            width="200"
            height="200"
            style="display:block; margin: 0 auto;"
          />
        </p>

        <p>Si no podés escanear el código, podés dictar este código en recepción:</p>
        <p><b>Código de turno:</b> ${apptId}</p>

        <p>Gracias por elegir ClinicHealth 🩺</p>
      `;


    // 4) Enviar email
    await transporter.sendMail({
      from: "ClinicHealth <TU_EMAIL@gmail.com>",   // 👈 tu remitente
      to: email,
      subject,
      html: htmlBody,
    });

    logger.info("📧 Email enviado a:", email);

    return;
  }
);
