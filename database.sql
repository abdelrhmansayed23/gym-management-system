CREATE DATABASE IF NOT EXISTS gym_platform
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE gym_platform;

-- ADMINS
CREATE TABLE admins (
    id              CHAR(36)        NOT NULL DEFAULT (UUID()),
    username        VARCHAR(60)     NOT NULL,
    email           VARCHAR(255)    NOT NULL,
    password_hash   TEXT            NOT NULL,
    full_name       VARCHAR(150)    NOT NULL,
    is_active       TINYINT(1)      NOT NULL DEFAULT 1,
    last_login_at   TIMESTAMP       NULL,
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    UNIQUE KEY uq_admins_username (username),
    UNIQUE KEY uq_admins_email    (email)
);

-- PACKAGES
CREATE TABLE packages (
    id              CHAR(36)        NOT NULL DEFAULT (UUID()),
    name            VARCHAR(100)    NOT NULL,
    description     TEXT            NULL,
    duration_days   INT             NOT NULL,
    price           DECIMAL(10, 2)  NOT NULL,
    is_active       TINYINT(1)      NOT NULL DEFAULT 1,
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    UNIQUE KEY uq_packages_name (name),
    CONSTRAINT chk_packages_duration CHECK (duration_days > 0),
    CONSTRAINT chk_packages_price    CHECK (price >= 0)
);


-- MEMBERS
CREATE TABLE members (
    id                          CHAR(36)        NOT NULL DEFAULT (UUID()),

    -- Personal info
    first_name                  VARCHAR(100)    NOT NULL,
    last_name                   VARCHAR(100)    NOT NULL,
    email                       VARCHAR(255)    NULL,
    phone                       VARCHAR(30)     NULL,
    date_of_birth               DATE            NULL,
    age                         TINYINT UNSIGNED GENERATED ALWAYS AS (TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE())) STORED,
    gender                      ENUM('male','female','other','prefer_not_to_say') NULL,
    weight_kg                   DECIMAL(5, 2)   NULL,
    height_cm                   DECIMAL(5, 2)   NULL,
    bmi                         DECIMAL(5, 2)   GENERATED ALWAYS AS (ROUND(weight_kg / NULLIF(POW(height_cm / 100.0, 2), 0), 2)) STORED,
    photo_url                   TEXT            NULL,
    emergency_contact_name      VARCHAR(150)    NULL,
    emergency_contact_phone     VARCHAR(30)     NULL,
    status                      ENUM('ACTIVE','SUSPENDED','DELETED') NOT NULL DEFAULT 'ACTIVE',
    notes                       TEXT            NULL,
    created_by                  CHAR(36)        NULL,
    created_at                  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at                  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    UNIQUE KEY uq_members_email (email),
    KEY idx_members_status      (status),
    KEY idx_members_name        (last_name, first_name),
    KEY idx_members_created_by  (created_by),

    CONSTRAINT fk_members_admin
        FOREIGN KEY (created_by) REFERENCES admins (id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT chk_members_weight CHECK (weight_kg > 0),
    CONSTRAINT chk_members_height CHECK (height_cm > 0)
);


-- MEMBERSHIPS
CREATE TABLE memberships (
    id                  CHAR(36)        NOT NULL DEFAULT (UUID()),
    member_id           CHAR(36)        NOT NULL,
    package_id          CHAR(36)        NOT NULL,
    start_date          DATE            NOT NULL,
    end_date            DATE            NOT NULL,
    amount_paid         DECIMAL(10, 2)  NOT NULL,
    payment_method      ENUM('CASH','CARD','INSTAPAY') NULL,
    status              ENUM('ACTIVE','SUSPENDED','EXPIRED','CANCELLED') NOT NULL DEFAULT 'ACTIVE',
    suspension_reason   TEXT            NULL,
    suspended_at        DATE            NULL,
    suspended_until     DATE            NULL,
    created_by          CHAR(36)        NULL,
created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    KEY idx_memberships_member_id   (member_id),
    KEY idx_memberships_package_id  (package_id),
    KEY idx_memberships_status      (status),
    KEY idx_memberships_end_date    (end_date),
    KEY idx_memberships_created_by  (created_by),

    CONSTRAINT fk_memberships_member
        FOREIGN KEY (member_id)  REFERENCES members  (id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_memberships_package
        FOREIGN KEY (package_id) REFERENCES packages (id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_memberships_admin
        FOREIGN KEY (created_by) REFERENCES admins   (id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT chk_memberships_dates
        CHECK (end_date > start_date),
    CONSTRAINT chk_memberships_amount
        CHECK (amount_paid >= 0),
    CONSTRAINT chk_memberships_suspension
        CHECK (suspended_until IS NULL OR suspended_until >= suspended_at)
);


-- SEED: default super-admin
INSERT INTO admins (id, username, email, password_hash, full_name)
VALUES (
    UUID(),
    'superadmin',
    'admin@gym.local',
    '$2b$12$PLACEHOLDER_REPLACE_WITH_REAL_BCRYPT_HASH',
    'Super Admin'
);
