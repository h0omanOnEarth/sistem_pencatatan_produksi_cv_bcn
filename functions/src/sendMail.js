const nodemailer = require("nodemailer");
const cors = require("cors");
const {
  log,
  info,
  debug,
  warn,
  error,
  write,
} = require("firebase-functions/logger");

const transporter = nodemailer.createTransport({
  service: "gmail",
  host: "smtp.gmail.com",
  port: 465,
  secure: true,
  auth: {
    user: "berliancangkirnusantara@gmail.com",
    pass: "auwh xoje pinq ldzc", //you your password
  },
});

exports.sendEmailNotif = async (req, res) => {
  const { dest, subject, html } = req.data;
  try {
    const mailOptions = {
      from: "CV. Berlian Cangkir Nusantara <berliancangkirnusantara@gmail.com>",
      to: dest,
      subject: subject,
      html: html,
    };
    await transporter.sendMail(mailOptions);
    return { success: true, message: "Sent" };
  } catch (error) {
    return { success: false, message: error.toString() };
  }
};
