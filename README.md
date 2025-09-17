# 💳 Credit Payment Analytics Pipeline

[![dbt](https://img.shields.io/badge/dbt-1.10.11-orange)](https://www.getdbt.com/)
[![BigQuery](https://img.shields.io/badge/BigQuery-Warehouse-blue)](https://cloud.google.com/bigquery)
[![Python](https://img.shields.io/badge/Python-3.8+-green)](https://www.python.org/)

## 📊 Overview
A comprehensive dbt project that analyses credit card payment behaviour to identify customers eligible for improved credit terms. Built as a portfolio project demonstrating advanced data transformation and business logic implementation skills.

## 🎯 Business Context
Traditional credit scoring focuses on risk minimisation. This project takes a **lender's perspective**, identifying profitable customers (revolvers) who generate interest revenue whilst maintaining acceptable risk levels.

### 💰 Key Business Insight
> "Good customers pay eventually. Great customers pay forever (in interest)."

### 💡 Key Discoveries from EDA
- **"Paid in full" ≠ Zero balance**: 90% of customers marked as paying in full still carry debt
- **Account in credit** (status -2): 7.6% of these customers have overpaid - lowest risk but unprofitable
- **Minimum payment only** (status 0): Most profitable customers when managed well
- **Payment status reflects statement balance**, not total debt

## 📈 Data Source
- **Dataset**: UCI Credit Card Clients Dataset (2005)
- **Size**: 30,000 customers
- **Period**: 6 months of payment history
- **Location**: Taiwan (amounts in NT$)

## 🏗️ Architecture

### Data Flow
```
EDA Analysis          → Discovered true payment status meanings
  ↓
seeds/               → Raw CSV data with corrected interpretations
  ↓
staging/             → Decoded with business-accurate labels
  ↓
intermediate/        → 5-tier scoring system + utilisation analysis
  ↓
marts/              → Action-oriented decisions
```

![Data Pipeline DAG](images/DAG.png)

## 🧮 Key Business Logic

### Customer Value Score (Discrete Values)
Prioritises profitable revolvers who generate interest revenue:

| Score | Customer Segment | Criteria | Business Value |
|-------|-----------------|----------|----------------|
| 🟢 100 | Premium Revolvers | No late, 3+ minimum payments, >$1000 avg balance | Highest profit potential |
| 🟢 80 | Standard Good | No late payments, >$500 avg balance | Reliable revenue |
| 🟡 60 | Acceptable Risk | 1 late payment OR low balance | Monitor for improvement |
| 🟠 40 | Multiple Risks | 2 late payments OR frequent overpayments | Intervention needed |
| 🔴 30 | Dormant | Minimal activity, <$100 avg balance | Re-engagement opportunity |
| 🔴 20 | Unusual Pattern | Edge cases | Manual review required |
| 🔴 15 | High Risk | 3+ late payments | Collections focus |

### 🎯 Recommended Actions Logic

| Action | Criteria | Business Rationale |
|--------|----------|-------------------|
| **INCREASE_LIMIT** | Score ≥80 AND 50-75% utilisation | Active, profitable, room to grow |
| **MAINTAIN** | Score ≥60 AND ≤85% utilisation | Stable, well-managed accounts |
| **MONITOR** | Score ≥80 with >85% utilisation OR other warning signs | Risk emerging despite good history |
| **REVIEW_ACCOUNT** | Score ≤40 OR >95% utilisation | Immediate intervention required |

### Risk Overrides
Even premium customers (score 80-100) are flagged for monitoring if:
- Utilisation exceeds 85% (financial stress indicator)
- Multiple months over credit limit (capacity issues)

## 📂 Models

| Model | Type | Purpose | Key Metrics |
|-------|------|---------|-------------|
| `stg_credit_card_data` | View | Transforms numeric codes to readable text | Decoded statuses, demographics |
| `int_payment_performance` | Table | Calculates payment reliability and customer value | 5-tier scoring system |
| `int_utilisation_analysis` | Table | Analyses credit usage patterns | Corrected for negative balances |
| `mart_customer_credit_profile` | Table | Complete customer view for decisions | Recommended actions |
| `mart_credit_portfolio_summary` | Table | Executive dashboard by risk segment | Portfolio distribution |

## 📊 Key Findings

### Portfolio Distribution (Actual Results)

| Action | % Customers | Count | Average Score | Avg Utilisation |
|--------|------------|-------|---------------|-----------------|
| 📈 INCREASE_LIMIT | 10.7% | 3,204 | 89.5 | 62.3% |
| ✅ MAINTAIN | 62.2% | 18,673 | 75.2 | 41.8% |
| ⚠️ MONITOR | 7.6% | 2,270 | 71.3 | 124.5% |
| 🚨 REVIEW_ACCOUNT | 19.5% | 5,853 | 34.1 | 87.2% |

### Risk Concentration
- **830** customers with 3+ late payments requiring immediate review
- **2,270** customers exceeding 90% utilisation showing financial stress
- **3,204** premium customers eligible for limit increases

## 🚀 Setup & Usage

### Prerequisites
- ✅ Python 3.8+
- ✅ dbt-core 1.10+
- ✅ Google BigQuery account
- ✅ Git

### 📦 Installation
```bash
# Clone repository
git clone https://github.com/yourusername/credit-payment-analytics.git
cd credit-payment-analytics

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Configure BigQuery connection
# Update ~/.dbt/profiles.yml with your credentials
```

### 🏃 Running the Pipeline
```bash
# Load raw data
dbt seed

# Run all transformations
dbt run

# Run tests
dbt test

# Generate and view documentation
dbt docs generate
dbt docs serve
```

## 🧪 Testing Strategy

### Test Coverage
- ✅ **27 tests** implemented across all models
- ✅ Business logic validation for recommended actions
- ✅ Edge case handling for score boundaries (40, 60, 80, 100)
- ✅ Utilisation calculation accuracy for negative balances
- ✅ Custom macros for data quality checks

### Test Results
```bash
Completed successfully
================== 
✓ 27 tests passed
✗ 0 tests failed
⚠ 0 warnings
```

### Key Test Validations
- All INCREASE_LIMIT customers have score ≥80 and 50-75% utilisation
- No premium customers (score ≥80) with >85% utilisation get MAINTAIN status
- All score ≤40 customers correctly flagged for REVIEW_ACCOUNT

## 📊 Interactive Documentation

Full interactive documentation is available via dbt docs:

```bash
# Generate documentation
dbt docs generate

# View interactive documentation with DAG
dbt docs serve
# Opens at http://localhost:8080
```

The documentation includes:
- Interactive DAG (Directed Acyclic Graph) of all models
- Model and column descriptions
- Test results and data lineage
- Searchable interface for all project components

## 🔮 Future Enhancements
- [ ] Add incremental loading for production scale
- [ ] Implement Looker Studio dashboard
- [ ] Add ML-based risk prediction
- [ ] Include time-series trend analysis
- [ ] Create API endpoints for real-time scoring
- [ ] Expand to multi-product analysis (Term Loans, FlexiPay, Asset Finance)

## 🛠️ Technologies Used

![dbt](https://img.shields.io/badge/dbt-FF6F61?style=for-the-badge&logo=dbt&logoColor=white)
![BigQuery](https://img.shields.io/badge/BigQuery-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)
![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white)

## 📁 Project Structure
```
credit_payment_analytics/
├── 📂 models/
│   ├── 📂 staging/
│   │   └── 📄 stg_credit_card_data.sql
│   ├── 📂 intermediate/
│   │   ├── 📄 int_payment_performance.sql
│   │   └── 📄 int_utilisation_analysis.sql
│   ├── 📂 marts/
│   │   ├── 📄 mart_customer_credit_profile.sql
│   │   └── 📄 mart_credit_portfolio_summary.sql
│   └── 📄 schema.yml
├── 📂 seeds/
│   └── 📄 raw_credit_card_data.csv
├── 📂 tests/
│   └── 📄 assert_recommended_action_logic.sql
├── 📂 macros/
│   └── 📄 test_positive_values.sql
├── 📂 analyses/
│   └── 📄 EDA.ipynb
├── 📄 dbt_project.yml
├── 📄 requirements.txt
└── 📄 README.md
```

## 📧 Contact
- **GitHub**: [bergerache](https://github.com/bergerache)
- **LinkedIn**: [rachel-berger-data](https://linkedin.com/in/rachel-berger-data)
- **Email**: bergerache@gmail.com

---

<p align="center">
  Made with ❤️ using dbt
</p>