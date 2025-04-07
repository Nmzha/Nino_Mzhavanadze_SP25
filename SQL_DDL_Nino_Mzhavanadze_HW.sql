CREATE SCHEMA campaign_data;

-- Donor table
-- Using BIGSERIAL for auto-increment primary key, TEXT for flexible name fields
-- Email and phone marked UNIQUE for identity assurance
-- full_name is GENERATED for consistency and to avoid redundancy
CREATE TABLE IF NOT EXISTS campaign_data.donor (
    donor_id      BIGSERIAL PRIMARY KEY,
    first_name    TEXT NOT NULL,  -- First name required
    last_name     TEXT NOT NULL,  -- Last name required
    email         TEXT UNIQUE NOT NULL,  -- Unique email ensures no duplicates
    phone         TEXT UNIQUE NOT NULL,  -- Phone is also unique for contact clarity
    full_name     TEXT GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED NOT NULL
);

-- Add timestamp to existing rows (example of ALTER logic for record_ts)
ALTER TABLE campaign_data.donor ADD COLUMN record_ts DATE DEFAULT current_date;
UPDATE campaign_data.donor SET record_ts = current_date WHERE record_ts IS NULL;

-- Sample data for donor
INSERT INTO campaign_data.donor (first_name, last_name, email, phone) VALUES
('Anna', 'Taylor', 'anna.taylor@example.com', '555-0001'),
('Brian', 'White', 'brian.white@example.com', '555-0002');


-- Campaign Event table
-- Date checked to be after 2000 for data relevance
-- Budget must be non-negative
CREATE TABLE IF NOT EXISTS campaign_data.campaign_event (
    event_id      BIGSERIAL PRIMARY KEY,
    event_name    TEXT NOT NULL,
    event_date    DATE NOT NULL CHECK (event_date > '2000-01-01'),
    location      TEXT NOT NULL,
    budget        NUMERIC(12,2) CHECK (budget >= 0)
);


ALTER TABLE campaign_data.campaign_event ADD COLUMN record_ts DATE DEFAULT current_date;
UPDATE campaign_data.campaign_event SET record_ts = current_date WHERE record_ts IS NULL;

-- Sample data for campaign_event
INSERT INTO campaign_data.campaign_event (event_name, event_date, location, budget) VALUES
('Youth Rally', '2023-08-01', 'Seattle', 5000.00),
('Education Forum', '2023-09-10', 'Boston', 8000.00);

-- Contribution table
-- Amounts must be non-negative and contributions dated appropriately
CREATE TABLE IF NOT EXISTS campaign_data.contribution (
    contribution_id BIGSERIAL PRIMARY KEY,
    donor_id        BIGINT NOT NULL REFERENCES campaign_data.donor(donor_id),
    event_id        BIGINT NOT NULL REFERENCES campaign_data.campaign_event(event_id),
    contribution_date DATE NOT NULL CHECK (contribution_date > '2000-01-01'),
    amount          NUMERIC(10,2) NOT NULL CHECK (amount >= 0)
);

ALTER TABLE campaign_data.contribution ADD COLUMN record_ts DATE DEFAULT current_date;
UPDATE campaign_data.contribution SET record_ts = current_date WHERE record_ts IS NULL;

-- Sample data for contribution
INSERT INTO campaign_data.contribution (donor_id, event_id, contribution_date, amount) VALUES
(1, 1, '2023-07-25', 1200.00),
(2, 2, '2023-09-01', 950.00);

-- Volunteer table
-- Gender field has a CHECK constraint to limit to expected values
-- Email and phone made unique to maintain individual identification
CREATE TABLE IF NOT EXISTS campaign_data.volunteer (
    volunteer_id  BIGSERIAL PRIMARY KEY,
    first_name    TEXT NOT NULL,
    last_name     TEXT NOT NULL,
    gender        TEXT CHECK (gender IN ('Male', 'Female', 'Other')) NOT NULL,  -- Gender restricted
    email         TEXT UNIQUE NOT NULL,
    phone         TEXT UNIQUE NOT NULL,
    full_name     TEXT GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED NOT NULL
);

ALTER TABLE campaign_data.volunteer ADD COLUMN record_ts DATE DEFAULT current_date;
UPDATE campaign_data.volunteer SET record_ts = current_date WHERE record_ts IS NULL;

-- Sample data for volunteer
INSERT INTO campaign_data.volunteer (first_name, last_name, gender, email, phone) VALUES
('Carmen', 'Lee', 'Female', 'carmen.lee@example.com', '555-0003'),
('Daniel', 'Brown', 'Male', 'daniel.brown@example.com', '555-0004');



-- Volunteer Role table
-- Text description allows for flexibility in role explanation
CREATE TABLE IF NOT EXISTS campaign_data.volunteer_role (
    role_id          BIGSERIAL PRIMARY KEY,
    role_name        TEXT NOT NULL,
    role_description TEXT
);


ALTER TABLE campaign_data.volunteer_role ADD COLUMN record_ts DATE DEFAULT current_date;
UPDATE campaign_data.volunteer_role SET record_ts = current_date WHERE record_ts IS NULL;

-- Sample data for volunteer_role
INSERT INTO campaign_data.volunteer_role (role_name, role_description) VALUES
('Logistics', 'Manages event logistics'),
('Outreach', 'Coordinates volunteer outreach');

-- Volunteer Assignment table
-- Composite PK on volunteer and role ensures a volunteer can hold each role only once
-- Dates checked for meaningfulness (post-2000)
CREATE TABLE IF NOT EXISTS campaign_data.volunteer_assignment (
    volunteer_id BIGINT NOT NULL REFERENCES campaign_data.volunteer(volunteer_id),
    role_id      BIGINT NOT NULL REFERENCES campaign_data.volunteer_role(role_id),
    start_date   DATE NOT NULL CHECK (start_date > '2000-01-01'),
    end_date     DATE,
    PRIMARY KEY (volunteer_id, role_id)
);

ALTER TABLE campaign_data.volunteer_assignment ADD COLUMN record_ts DATE DEFAULT current_date;
UPDATE campaign_data.volunteer_assignment SET record_ts = current_date WHERE record_ts IS NULL;

-- Sample data for volunteer_assignment
INSERT INTO campaign_data.volunteer_assignment (volunteer_id, role_id, start_date) VALUES
(1, 1, '2023-06-01'),
(2, 2, '2023-06-05');

-- Volunteer Event bridge table
-- Allows mapping volunteers to events with details like task and hours
CREATE TABLE IF NOT EXISTS campaign_data.volunteer_event (
    volunteer_id    BIGINT NOT NULL REFERENCES campaign_data.volunteer(volunteer_id),
    event_id        BIGINT NOT NULL REFERENCES campaign_data.campaign_event(event_id),
    assigned_task   TEXT,
    hours_assigned  NUMERIC(4,1) CHECK (hours_assigned >= 0),  -- Enforcing no negative hours
    PRIMARY KEY (volunteer_id, event_id)
);

ALTER TABLE campaign_data.volunteer_event ADD COLUMN record_ts DATE DEFAULT current_date;
UPDATE campaign_data.volunteer_event SET record_ts = current_date WHERE record_ts IS NULL;

-- Sample data for volunteer_event
INSERT INTO campaign_data.volunteer_event (volunteer_id, event_id, assigned_task, hours_assigned) VALUES
(1, 1, 'Setup', 4.0),
(2, 2, 'Security', 3.5);

-- Problem table
-- Severity is constrained to a finite set to allow categorization
CREATE TABLE IF NOT EXISTS campaign_data.problem (
    problem_id          BIGSERIAL PRIMARY KEY,
    event_id            BIGINT NOT NULL REFERENCES campaign_data.campaign_event(event_id),
    problem_description TEXT,
    date_reported       DATE NOT NULL CHECK (date_reported > '2000-01-01'),
    severity            TEXT NOT NULL CHECK (severity IN ('Low', 'Medium', 'High'))
);

ALTER TABLE campaign_data.problem ADD COLUMN record_ts DATE DEFAULT current_date;
UPDATE campaign_data.problem SET record_ts = current_date WHERE record_ts IS NULL;

-- Sample data for problem
INSERT INTO campaign_data.problem (event_id, problem_description, date_reported, severity) VALUES
(1, 'Power outage during event', '2023-08-01', 'High'),
(2, 'Not enough chairs', '2023-09-10', 'Medium');

-- Expense table
-- Monetary amount must be positive, date checked to be valid
CREATE TABLE IF NOT EXISTS campaign_data.expense (
    expense_id     BIGSERIAL PRIMARY KEY,
    event_id       BIGINT NOT NULL REFERENCES campaign_data.campaign_event(event_id),
    expense_date   DATE NOT NULL CHECK (expense_date > '2000-01-01'),
    expense_amount NUMERIC(10,2) CHECK (expense_amount >= 0),
    category       TEXT NOT NULL,
    payee          TEXT NOT NULL
);

ALTER TABLE campaign_data.expense  ADD COLUMN record_ts DATE DEFAULT current_date;
UPDATE campaign_data.expense SET record_ts = current_date WHERE record_ts IS NULL;

-- Sample data for expense
INSERT INTO campaign_data.expense (event_id, expense_date, expense_amount, category, payee) VALUES
(1, '2023-07-30', 650.00, 'Rentals', 'City Equipment Co.'),
(2, '2023-09-05', 400.00, 'Catering', 'Eastside Foods');

-- Survey table
-- Allows tracking feedback tied to specific events
CREATE TABLE IF NOT EXISTS campaign_data.survey (
    survey_id    BIGSERIAL PRIMARY KEY,
    event_id     BIGINT NOT NULL REFERENCES campaign_data.campaign_event(event_id),
    survey_name  TEXT NOT NULL,
    survey_date  DATE NOT NULL CHECK (survey_date > '2000-01-01'),
    target_group TEXT
);

ALTER TABLE campaign_data.survey ADD COLUMN record_ts DATE DEFAULT current_date;
UPDATE campaign_data.survey SET record_ts = current_date WHERE record_ts IS NULL;

-- Sample data for survey
INSERT INTO campaign_data.survey (event_id, survey_name, survey_date, target_group) VALUES
(1, 'Youth Rally Feedback', '2023-08-02', 'Attendees'),
(2, 'Forum Opinions', '2023-09-11', 'Teachers');

-- Survey Question table
-- Plain TEXT used to allow open-ended or closed questions
CREATE TABLE IF NOT EXISTS campaign_data.survey_question (
    question_id   BIGSERIAL PRIMARY KEY,
    survey_id     BIGINT NOT NULL REFERENCES campaign_data.survey(survey_id),
    question_text TEXT NOT NULL
);

ALTER TABLE campaign_data.survey_question ADD COLUMN record_ts DATE DEFAULT current_date;
UPDATE campaign_data.survey_question SET record_ts = current_date WHERE record_ts IS NULL;

-- Sample data for survey_question
INSERT INTO campaign_data.survey_question (survey_id, question_text) VALUES
(1, 'How would you rate the organization?'),
(2, 'What did you enjoy most about the forum?');

-- Voter table
-- Includes address for localization and tracking responses by demographic
CREATE TABLE IF NOT EXISTS campaign_data.voter (
    voter_id      BIGSERIAL PRIMARY KEY,
    first_name    TEXT NOT NULL,
    last_name     TEXT NOT NULL,
    date_of_birth DATE NOT NULL,
    address       TEXT NOT NULL,
    full_name     TEXT GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED NOT NULL
);

ALTER TABLE campaign_data.voter ADD COLUMN record_ts DATE DEFAULT current_date;
UPDATE campaign_data.voter SET record_ts = current_date WHERE record_ts IS NULL;

-- Sample data for voter
INSERT INTO campaign_data.voter (first_name, last_name, date_of_birth, address) VALUES
('Emily', 'Clark', '1989-03-15', '12 Maple Drive'),
('George', 'King', '1993-11-07', '44 Sunset Blvd');

-- Survey Response table
-- Connects voter and question with their answer, supports multiple surveys
CREATE TABLE IF NOT EXISTS campaign_data.survey_response (
    response_id    BIGSERIAL PRIMARY KEY,
    question_id    BIGINT NOT NULL REFERENCES campaign_data.survey_question(question_id),
    voter_id       BIGINT NOT NULL REFERENCES campaign_data.voter(voter_id),
    response_value TEXT NOT null
);

ALTER TABLE campaign_data.survey_response ADD COLUMN record_ts DATE DEFAULT current_date;
UPDATE campaign_data.survey_response SET record_ts = current_date WHERE record_ts IS NULL;

-- Sample data for survey_response
INSERT INTO campaign_data.survey_response (question_id, voter_id, response_value) VALUES
(1, 1, 'Very Good'),
(2, 2, 'The panel discussion');

