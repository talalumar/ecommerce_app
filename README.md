# 🛒 E-Commerce App (Flutter + Node.js)

A full-stack **E-Commerce application** built with **Flutter (Frontend)** and **Node.js (Backend)**.  
The app supports **user & admin roles**, **secure authentication**, **email verification**, **product management**, **cart & orders**, and **Stripe test payments**.

---

## 🚀 Features

### 👤 User Features
- User signup & login
- Email verification using **OTP**
- OTP expires automatically after **3 minutes**
- Browse products
- Add products to cart
- Place orders
- Online card payment using **Stripe (Test Mode)**

### 🛠️ Admin Features
- Admin authentication
- Add new products
- Edit existing products
- Delete products
- Manage product listings

---

## 🔐 Authentication & Verification
- Custom authentication system
- Verification code (OTP) sent via **Gmail**
- Emails sent using **Nodemailer**
- OTP stored in **Redis (Upstash)** with **3-minute expiry**
- OTP auto-deletes after expiration
- Verified users are saved in **MongoDB Atlas**

---

## 🧰 Tech Stack

### Frontend
- **Flutter**
- Dart
- REST API integration

### Backend
- **Node.js**
- Express.js
- MongoDB Atlas
- Upstash Redis
- Nodemailer
- Stripe (Test Mode)

---

## 🗄️ Database & Services

| Service | Usage |
|------|------|
MongoDB Atlas | User, product, order storage |
Cloudinary | Product image storage |
Upstash Redis | OTP storage with expiry |
Stripe | Online payments (test cards) |
Gmail (Nodemailer) | Email verification |

---

## 🖼️ Image Storage
- Product images are uploaded and stored securely using **Cloudinary**
- Image URLs are saved in MongoDB

---

## 💳 Payment Integration
- Integrated **Stripe Test API**
- Users can pay using test card details
- Secure payment intent handling

---

## 🧪 OTP Verification Flow
1. User signs up
2. OTP generated on backend
3. OTP sent to user’s Gmail
4. OTP stored in Redis with 3-minute TTL
5. User verifies OTP
6. OTP auto-deleted
7. User saved in MongoDB

---

## 📂 Project Structure

ecommerce-app/
│
├── frontend/ # Flutter App
│
├── backend/ # Node.js + Express
│ ├── controllers
│ ├── routes
│ ├── models
│ ├── config
│ └── index.js


---

## ⚙️ Environment Variables

Create a `.env` file in the backend folder:

```env
PORT=3000
MONGODB_URI=your_mongodb_atlas_url
CLOUDINARY_NAME=your_cloudinary_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
STRIPE_SECRET_KEY=your_stripe_secret_key
UPSTASH_REDIS_REST_URL=your_upstash_url
UPSTASH_REDIS_REST_TOKEN=your_upstash_token
EMAIL_USER=your_gmail
EMAIL_PASS=your_gmail_app_password


▶️ Run the Project
Backend
cd backend
npm install
npm run dev

Frontend
cd frontend
flutter pub get
flutter run

🧑‍💻 Author
Talal Umar
Flutter Developer
Node.js Backend Developer
MongoDB & REST API Enthusiast

📌 Notes
Stripe is used in test mode
OTP verification is time-limited for security
Nodemon is used for backend development only
