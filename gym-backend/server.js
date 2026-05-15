const express = require("express");
const mysql = require("mysql2");
const { v4: uuidv4 } = require("uuid");

const app = express();
app.use(express.json());

// =====================
// DATABASE CONNECTION
// =====================
const db = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "",
  database: "gym_platform"
});

db.connect((err) => {
  if (err) {
    console.log("Database error:", err);
  } else {
    console.log("MySQL Connected ✅");
  }
});

// =====================
// TEST ROUTE
// =====================
app.get("/", (req, res) => {
  res.send("Gym API is running 🚀");
});

// =====================
// GET ALL MEMBERS
// =====================
app.get("/members", (req, res) => {
  db.query("SELECT * FROM members", (err, result) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(result);
  });
});

// =====================
// ADD MEMBER (WITH DUPLICATE CHECK)
// =====================
app.post("/members", (req, res) => {
  const { first_name, last_name, email, membership_duration } = req.body;

  // check duplicate email
  db.query("SELECT * FROM members WHERE email = ?", [email], (err, result) => {
    if (err) return res.status(500).json({ error: err.message });

    if (result.length > 0) {
      return res.status(400).json({ message: "Email already exists ❌" });
    }

    const id = uuidv4();

    const startDate = new Date();
    const endDate = new Date();
    endDate.setMonth(endDate.getMonth() + membership_duration);

    const sql = `
      INSERT INTO members 
      (id, first_name, last_name, email, membership_start, membership_end)
      VALUES (?, ?, ?, ?, ?, ?)
    `;

    db.query(sql, [id, first_name, last_name, email, startDate, endDate], (err) => {
      if (err) return res.status(500).json({ error: err.message });

      res.json({
        message: "Member added successfully ✅",
        id
      });
    });
  });
});

// =====================
// GET PACKAGES
// =====================
app.get("/packages", (req, res) => {
  db.query("SELECT * FROM packages", (err, result) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(result);
  });
});

// =====================
// ADD PACKAGE
// =====================
app.post("/packages", (req, res) => {
  const { name, price, duration_days } = req.body;

  const id = uuidv4();

  const sql = `
    INSERT INTO packages (id, name, price, duration_days)
    VALUES (?, ?, ?, ?)
  `;

  db.query(sql, [id, name, price, duration_days], (err) => {
    if (err) return res.status(500).json({ error: err.message });

    res.json({
      message: "Package created ✅",
      id
    });
  });
});

// =====================
// CREATE MEMBERSHIP (REAL LOGIC)
// =====================
app.post("/memberships", (req, res) => {
  const { member_id, package_id } = req.body;

  const getPackage = `
    SELECT duration_days FROM packages WHERE id = ?
  `;

  db.query(getPackage, [package_id], (err, result) => {
    if (err) return res.status(500).json({ error: err.message });

    if (result.length === 0) {
      return res.status(404).json({ message: "Package not found ❌" });
    }

    const duration = result[0].duration_days;

    const id = uuidv4();

    const start = new Date();
    const end = new Date();
    end.setDate(end.getDate() + duration);

    const sql = `
      INSERT INTO memberships
      (id, member_id, package_id, start_date, end_date)
      VALUES (?, ?, ?, ?, ?)
    `;

    db.query(sql, [id, member_id, package_id, start, end], (err) => {
      if (err) return res.status(500).json({ error: err.message });

      res.json({
        message: "Membership created successfully ✅",
        id
      });
    });
  });
});

// =====================
// START SERVER
// =====================
app.listen(3000, () => {
  console.log("Server running on port 3000 🚀");
});