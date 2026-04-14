# 🏋️ Gym Management System

## 📌 Project Overview
This system is designed to manage a gym's operations, including members, packages, and memberships. It allows admins to handle user data, assign packages, and track subscription status.

---

## 👤 Admins
Admins manage the whole system.

**Main Features:**
- Create members
- Create packages
- Assign memberships

**Fields:**
- id (Primary Key)
- username
- email
- password_hash
- full_name
- last_login_at
- created_at

---

## 🧍 Members
Represents gym clients.

**Fields:**
- id (Primary Key)
- first_name
- last_name
- email
- phone
- date_of_birth
- age
- gender
- weight_kg
- height_cm
- bmi
- photo_url
- emergency_contact_name
- emergency_contact_phone
- status
- created_at
- updated_at

---

## 📦 Packages
Defines subscription plans.

**Fields:**
- id (Primary Key)
- name
- description
- duration_days
- price
- is_active
- created_at

---

## 🪪 Memberships
Links members to packages.

**Fields:**
- id (Primary Key)
- member_id (Foreign Key)
- package_id (Foreign Key)
- start_date
- end_date
- amount_paid
- payment_method
- status
- suspension_reason
- suspended_at
- suspended_until
- created_at
- updated_at

---

## 🔗 Relationships
- One Admin can create many Members
- One Member can have many Memberships
- One Package can be used in many Memberships

---

## ⚙️ Constraints
- end_date must be greater than start_date
- amount_paid must be >= 0
- suspended_until must be after suspended_at

---

## 🔐 Security
- Passwords are stored as hashed values
- Default super admin is created

---

## 🧪 Default Data
- Username: superadmin
- Email: admin@gym.local

---

## 🚀 Workflow
1. Admin creates a package
2. Admin registers a member
3. Admin assigns a membership
4. System tracks membership status

---

## 📊 Use Case Example
A new member registers → selects a package → pays → membership is activated