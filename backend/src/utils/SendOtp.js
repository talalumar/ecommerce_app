import { Resend } from "resend";

const resend = new Resend(process.env.RESEND_API_KEY);

// Function to send OTP email
const sendOtpEmail = async (to, name, otp) => {
  try {
    await resend.emails.send({
      from: process.env.EMAIL_FROM, // onboarding@resend.dev
      to,
      subject: "Your OTP Code for Ecommerce Registration",
      html: `
        <p>Hello ${name},</p>
        <p>Your OTP for registration is:</p>
        <h2>${otp}</h2>
        <p>This code will expire in 3 minutes.</p>
      `,
    });
  } catch (error) {
    console.error("Resend email error:", error);
    throw error; // IMPORTANT
  }
};

export { sendOtpEmail };



// import nodemailer from "nodemailer";

// // Create transporter once
// const transporter = nodemailer.createTransport({
//   service: "gmail",
//   auth: {
//     user: process.env.EMAIL_USER, // your Gmail address
//     pass: process.env.EMAIL_PASS, // Gmail App Password
//   },
// });

// // Function to send OTP email
// const sendOtpEmail = async (to, name, otp) => {
//   await transporter.sendMail({
//     from: `"Ecommerce App" <${process.env.EMAIL_USER}>`,
//     to, // use function param
//     subject: "Your OTP Code for Ecommerce Registration",
//     html: `
//       <p>Hello ${name},</p>
//       <p>Your OTP for registration is:</p>
//       <h2>${otp}</h2>
//       <p>This code will expire in 5 minutes.</p>
//     `,
//   });
// };

// export { sendOtpEmail };
