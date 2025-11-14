# 📚 SkillShare – Flutter Mobile App

Collaborative platform to connect students, share knowledge, and organize study groups in real time.

## 🧩 General Description

**SkillShare** is a mobile application developed in **Flutter** that allows users to create, discover, and join study groups in different subjects. The app integrates with a backend developed in **ASP.NET Core**, following DDD and CQRS principles, and communicates via RESTful API.

The goal is to provide a smooth experience for managing study sessions, coordinating subjects, interacting with other students, and keeping track of academic interests.

## ✨ Main Features

* 🔐 **Secure authentication with JWT**
* 👥 **Study group management**

  * Create groups
  * Join or leave groups
  * View details, members, and associated subjects
* 📚 **Management of subjects / highlighted subjects**
* 👤 **User profile** with academic interests
* 📡 **REST API consumption** (ASP.NET Core)
* 🌗 **Dark/light theme**
* 📱 **Modern and responsive UI** using Material Design 3

## 🛠️ Technologies Used

* **Flutter 3.x**
* **Dart**
* **State Management:** Provider or Riverpod
* **HTTP Client:** `dio` or `http`
* **Local persistence:** `shared_preferences`
* **Backend:** ASP.NET Core + EF Core + MySQL
* **Authentication:** JWT

## 🔧 Environment Setup

### 1️⃣ Clone repository

```bash
git clone https://github.com/ThinkUp-SkillShare/flutter-mobile-application.git
cd flutter-mobile-application
```

### 2️⃣ Install dependencies

```bash
flutter pub get
```

### 3️⃣ Configure environment variables

Create a `.env` file (if using flutter_dotenv):

```env
API_BASE_URL=https://tu-api.com/api
```

### 4️⃣ Run the app

```bash
flutter run
```

## 🚀 Upcoming Improvements

* Real-time chat for groups (WebSockets)
* Push notifications (Firebase)
* Advanced group search
* Roles (admin, moderator)
* Dynamic Material You

## 📄 License

MIT License.

## 🛠️ Team

1. [Jhosep Argomedo](https://github.com/JhosepAC)
2. [Sebastian Ramirez](https://github.com/SRT0808)
3. [Renso Julca](https://github.com/rajc02)
4. [Carlos Gonzalez](https://github.com/CarlosGC-LP)

## 📬 Contact

Questions, suggestions, or comments?
Feel free to write to us at: **[support@skillshare.com](mailto:support@skillshare.com)**