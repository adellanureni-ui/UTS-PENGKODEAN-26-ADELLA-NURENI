-- =============================================================================
-- SOAL 1.2: DDL SKEMA GENERAL LEDGER & KEKANGAN INTEGRITAS (POSTGRESQL)
-- Berkas Repositori GitHub: soal1/01_schema_general_ledger.sql
-- =============================================================================

-- 1. TABEL CHART OF ACCOUNTS (Bagan Akun Master)
CREATE TABLE chart_of_accounts (
    account_id            INTEGER GENERATED ALWAYS AS IDENTITY,
    account_code          VARCHAR(20)  NOT NULL,
    account_name          VARCHAR(100) NOT NULL,
    normal_balance        VARCHAR(10)  NOT NULL,
    report_classification VARCHAR(50)  NOT NULL,

    -- Primary Key & Unique Constraints
    CONSTRAINT pk_chart_of_accounts PRIMARY KEY (account_id),
    CONSTRAINT uq_account_code UNIQUE (account_code),

    -- CHECK Constraint Nilai Saldo Normal
    CONSTRAINT ck_normal_balance CHECK (normal_balance IN ('DEBIT', 'CREDIT'))
);

-- 2. TABEL JOURNAL HEADERS (Header Bukti Transaksi)
CREATE TABLE journal_headers (
    id               BIGINT GENERATED ALWAYS AS IDENTITY,
    transaction_date DATE        NOT NULL,
    reference_no     VARCHAR(50) NOT NULL,
    description      TEXT,
    posting_status   VARCHAR(20) NOT NULL DEFAULT 'DRAFT',

    -- Primary Key & Unique Constraints
    CONSTRAINT pk_journal_headers PRIMARY KEY (id),
    CONSTRAINT uq_reference_no UNIQUE (reference_no),

    -- CHECK Constraint Status Posting Jurnal
    CONSTRAINT ck_posting_status CHECK (posting_status IN ('DRAFT', 'POSTED', 'REVERSED'))
);

-- 3. TABEL JOURNAL LINES (Detail Baris Jurnal Akuntansi)
CREATE TABLE journal_lines (
    id         BIGINT GENERATED ALWAYS AS IDENTITY,
    header_id  BIGINT        NOT NULL,
    account_id INTEGER       NOT NULL,
    debit      NUMERIC(18,2) NOT NULL DEFAULT 0,
    credit     NUMERIC(18,2) NOT NULL DEFAULT 0,

    -- Primary Key
    CONSTRAINT pk_journal_lines PRIMARY KEY (id),

    -- Foreign Key Constraints dengan Klausa ON DELETE RESTRICT
    CONSTRAINT fk_lines_header FOREIGN KEY (header_id)
        REFERENCES journal_headers (id) ON DELETE RESTRICT,
    CONSTRAINT fk_lines_account FOREIGN KEY (account_id)
        REFERENCES chart_of_accounts (account_id) ON DELETE RESTRICT,

    -- CHECK Constraints Integritas Nominal & Nilai
    CONSTRAINT ck_lines_debit_nonneg  CHECK (debit >= 0),
    CONSTRAINT ck_lines_credit_nonneg CHECK (credit >= 0),
    CONSTRAINT ck_lines_not_both_zero CHECK (NOT (debit = 0 AND credit = 0)),
    CONSTRAINT ck_lines_one_side      CHECK (NOT (debit > 0 AND credit > 0))
);
