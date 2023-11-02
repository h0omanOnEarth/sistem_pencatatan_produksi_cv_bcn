const nodemailer = require("nodemailer");

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

exports.sendEmailNotif = async (req) => {
  const { dest, subject, html } = req.data;
  const mailOptions = {
    from: "CV. Berlian Cangkir Nusantara <berliancangkirnusantara@gmail.com>",
    to: dest,
    subject: subject,
    html: html,
  };
  try {
    await transporter.sendMail(mailOptions);
    return { success: true, message: "Email sent successfully" };
  } catch (error) {
    return { success: false, message: error.toString() };
  }
};
