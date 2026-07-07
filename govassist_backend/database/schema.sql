CREATE DATABASE IF NOT EXISTS govassist_db;
USE govassist_db;

CREATE TABLE IF NOT EXISTS categories (
    id VARCHAR(50) PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    iconAsset VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS services (
    id VARCHAR(50) PRIMARY KEY,
    category_id VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    titleLocal VARCHAR(255),
    description TEXT,
    descriptionLocal TEXT,
    procedures TEXT,
    proceduresLocal TEXT,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS requirements (
    id VARCHAR(50) PRIMARY KEY,
    service_id VARCHAR(50) NOT NULL,
    name VARCHAR(255) NOT NULL,
    nameLocal VARCHAR(255),
    description TEXT,
    descriptionLocal TEXT,
    is_required BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS eligibility_questions (
    id VARCHAR(50) PRIMARY KEY,
    service_id VARCHAR(50) NOT NULL,
    question_text TEXT NOT NULL,
    question_textLocal TEXT,
    expected_answer BOOLEAN NOT NULL,
    options JSON DEFAULT NULL,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS faqs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    question TEXT NOT NULL,
    answer TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS assessments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    service_title VARCHAR(255) NOT NULL,
    date DATETIME NOT NULL,
    is_eligible BOOLEAN NOT NULL,
    reference_number VARCHAR(100) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS inquiries (
    id VARCHAR(50) PRIMARY KEY,
    user_id INT NOT NULL,
    subject VARCHAR(255) NOT NULL,
    status VARCHAR(50) NOT NULL,
    date_submitted DATETIME NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id VARCHAR(50) NOT NULL,
    message_text TEXT NOT NULL,
    is_user BOOLEAN NOT NULL,
    timestamp DATETIME NOT NULL,
    FOREIGN KEY (ticket_id) REFERENCES inquiries(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at DATETIME NOT NULL,
    email_verified_at DATETIME DEFAULT NULL,
    verification_code VARCHAR(10) DEFAULT NULL,
    dob DATE DEFAULT NULL,
    address TEXT DEFAULT NULL,
    civil_status VARCHAR(50) DEFAULT NULL,
    contact_number VARCHAR(50) DEFAULT NULL,
    valid_id_path VARCHAR(255) DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at DATETIME NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS applications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    service_id VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,
    submitted_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE
);

-- Mock Data Insertion

INSERT INTO users (full_name, email, password_hash, created_at) VALUES 
('Admin User', 'admin@ssfo.gov.ph', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', NOW()); -- Password is 'password'

INSERT INTO categories (id, title, iconAsset) VALUES 
('cat_1', 'Civil Registry', 'assets/icons/civil.png'),
('cat_2', 'Licenses & Permits', 'assets/icons/license.png');

INSERT INTO services (id, category_id, title, titleLocal, description, descriptionLocal, procedures, proceduresLocal) VALUES
('srv_1', 'cat_1', 'Birth Certificate', 'Sertipiko ng Kapanganakan', 'Get a certified true copy of a birth certificate.', 'Kumuha ng sertipikadong kopya ng sertipiko ng kapanganakan.', '1. Submit reqs\n2. Pay fee\n3. Claim', '1. Ibigay ang requirements\n2. Magbayad\n3. Kunin'),
('srv_2', 'cat_2', 'Driver''s License', 'Lisensya sa Pagmamaneho', 'Apply for or renew your driver''s license.', 'Mag-apply o mag-renew ng lisensya.', '1. Medical\n2. Exam\n3. Print', '1. Medical\n2. Exam\n3. Print');

INSERT INTO requirements (id, service_id, name, nameLocal, description, descriptionLocal, is_required) VALUES
('req_1', 'srv_1', 'Valid ID', 'Valid ID', 'Any government issued ID', 'Kahit anong ID galing sa gobyerno', TRUE),
('req_2', 'srv_2', 'Medical Certificate', 'Medical Certificate', 'LTO accredited medical clinic', 'LTO accredited medical clinic', TRUE);

INSERT INTO eligibility_questions (id, service_id, question_text, question_textLocal, expected_answer) VALUES
('eq_1', 'srv_1', 'Are you the document owner or an authorized representative?', 'Ikaw ba ang may-ari ng dokumento o awtorisadong kinatawan?', TRUE),
('eq_2', 'srv_2', 'Are you at least 17 years old?', 'Ikaw ba ay hindi bababa sa 17 taong gulang?', TRUE);

INSERT INTO faqs (question, answer) VALUES
('What are the accepted valid IDs?', 'We accept Passport, Driver''s License, UMID, Postal ID, and National ID.'),
('How long does it take to process a birth certificate?', 'Processing usually takes 3-5 working days.');

