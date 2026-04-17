# Advanced Supply Chain Risk Analysis System

A full-stack supply chain risk analysis system that integrates shipment data with routes, ports, weather conditions, and tracking logs to automatically detect risks, analyze delay causes, rank performance, and provide dashboard insights.

## Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Database | MySQL | Core data storage, triggers, views, stored procedures |
| Backend | Python + Flask | REST API and query execution |
| DB Connector | mysql.connector | Python-MySQL communication |
| Frontend | HTML + CSS + JavaScript | User interface, forms, and tables |
| Charts | Chart.js | Data visualization on dashboard |

## Features

- **Auto-derived Delay Calculation** — Delay hours computed automatically by a MySQL trigger using route expected duration. No manual entry required.
- **Risk Detection** — Shipments flagged as high-risk when delay exceeds 24 hours.
- **Carrier & Shipment Ranking** — Window functions (RANK, DENSE_RANK) rank shipments globally and per-route.
- **Weather Correlation** — Links severe weather events at origin/destination ports to shipment delays.
- **Above-Average Delay Detection** — Subquery-driven view identifies shipments exceeding overall average delay.
- **Interactive Dashboard** — Chart.js bar charts for delay-per-route and carrier performance.
- **Input Validation** — Client-side and server-side validation on the Add Shipment form.
- **Status Lifecycle Tracking** — Full shipment status history via status logs table with auto-logging trigger.

## Database Design

### 7 Tables

| Table | Description |
|-------|-------------|
| `ports` | 15 major global container ports |
| `carriers` | 10 real shipping lines with reliability scores |
| `routes` | 20 real sea routes with distances and expected durations |
| `shipments` | Shipment records with auto-computed delay fields |
| `weather_conditions` | Weather events with severity levels |

### SQL Concepts Used

- Multi-table JOINs (up to 5 tables)
- LEFT JOIN
- Aggregation (AVG, COUNT, SUM, GROUP BY, ROUND)
- Subqueries (in WHERE clause)
- Window Functions (RANK, DENSE_RANK, PARTITION BY)
- 5 Views
- 2 Triggers (BEFORE INSERT, AFTER UPDATE)
- 2 Stored Procedures (with transactions)
- 5 Indexes on foreign keys
- Constraints (PK, FK, NOT NULL, CHECK, DEFAULT, ON DELETE CASCADE)
- Date functions (DATE_ADD, DATE_SUB, TIMESTAMPDIFF)
- Error handling (SIGNAL SQLSTATE)
- Transaction control (START TRANSACTION, COMMIT)

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/shipments` | All shipments with joined route, carrier, port data |
| GET | `/high-risk` | High-risk shipments (delay > 24h) from view |
| GET | `/avg-delay-route` | Average delay per route from view |
| GET | `/carrier-performance` | Carrier stats from view |
| GET | `/ranked-shipments` | Ranked shipments using window functions |
| GET | `/above-avg-delay` | Shipments exceeding average delay from view |
| GET | `/weather-correlation` | Weather events correlated with delays from view |
| POST | `/add-shipment` | Insert new shipment via stored procedure |

## Frontend Pages

1. **Dashboard** — Summary metrics, average delay per route bar chart, carrier performance chart
2. **Shipments** — Full shipments table with search and filter by status/cargo type
3. **Risk Analysis** — High-risk shipments, above-average delays, weather correlation, delay rankings
4. **Add Shipment** — Validated form that calls the stored procedure via the API

## Project Structure

```
project/
├── database/
│   ├── schema.sql              # 7 tables, indexes, constraints
│   ├── sample_data.sql         # 350+ rows of realistic data
│   ├── triggers.sql            # BEFORE INSERT + AFTER UPDATE triggers
│   ├── stored_procedures.sql   # sp_add_shipment + sp_update_shipment_status
│   └── views.sql               # 5 views (high risk, avg delay, carrier perf, above avg, weather)
├── backend/
│   ├── app.py                  # Flask app entry point
│   ├── db.py                   # MySQL connection config
│   ├── validation.py           # Input validation for POST endpoint
│   ├── requirements.txt        # Python dependencies
│   └── routes/
│       ├── shipments.py        # GET /shipments, POST /add-shipment
│       ├── risk.py             # GET /high-risk, /ranked-shipments, /above-avg-delay, /weather-correlation
│       └── analytics.py        # GET /avg-delay-route, /carrier-performance
└── frontend/
    ├── index.html              # Dashboard page
    ├── shipments.html          # Shipments list page
    ├── risk.html               # Risk analysis page
    ├── add_shipment.html       # Add shipment form page
    ├── style.css               # Shared stylesheet
    └── charts.js               # API calls, chart rendering, table population
```

## Setup

### Prerequisites

- MySQL 8.0+
- Python 3.8+
- pip

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/ynamkit13/supply-chain-risk-analysis.git
   cd supply-chain-risk-analysis
   ```

2. **Set up the database**
   ```bash
   mysql -u root -p < database/schema.sql
   mysql -u root -p supply_chain_db < database/sample_data.sql
   ```

3. **Configure database credentials**

   Edit `backend/db.py` and set your MySQL password:
   ```python
   DB_CONFIG = {
       'host': 'localhost',
       'user': 'root',
       'password': 'your_password',
       'database': 'supply_chain_db'
   }
   ```

4. **Install Python dependencies**
   ```bash
   cd backend
   pip install -r requirements.txt
   ```

5. **Start the backend server**
   ```bash
   python app.py
   ```
   Server runs on `http://localhost:5001`

6. **Open the frontend**

   Open `frontend/index.html` in a browser.

## Sample Data

All sample data is based on real-world shipping data:

- **Ports** — Top 15 global container ports by throughput (Shanghai, Singapore, Rotterdam, Los Angeles, etc.)
- **Carriers** — 10 real shipping lines with reliability scores from Sea-Intelligence reports
- **Routes** — 20 actual sea routes with real distances via Suez/Panama canals
- **Weather** — Seasonal patterns (typhoons Jul-Oct in Asia, North Sea storms Nov-Mar, monsoons May-Sep)
- **Congestion** — Real documented events (LA/Long Beach COVID crisis, Shanghai lockdowns, Red Sea diversions)
- **Shipments** — 35 shipments with ~60% on-time and ~40% delayed, correlated with weather events
