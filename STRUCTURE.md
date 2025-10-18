# Neo4j Mastering Course - Directory Structure

## 📁 Course Organization

```
neo4j_mastering/
│
├── labs/                                # All 17 lab files
│   ├── neo4j_lab_1_enterprise_setup.md
│   ├── neo4j_lab_2_cypher_fundamentals.md
│   ├── neo4j_lab_3_claims_financial_modeling.md
│   ├── neo4j_lab_4_bulk_data_import.md
│   ├── neo4j_lab_5_advanced_analytics.md
│   ├── neo4j_lab_6_customer_analytics.md
│   ├── neo4j_lab_7_graph_algorithms.md
│   ├── neo4j_lab_8_performance_optimization.md
│   ├── neo4j_lab_9_fraud_detection.md
│   ├── neo4j_lab_10_compliance_audit.md
│   ├── neo4j_lab_11_predictive_analytics.md
│   ├── neo4j_lab_12.md
│   ├── neo4j_lab_13.md
│   ├── neo4j_lab_14.md
│   ├── neo4j_lab_15.md
│   ├── neo4j_lab_16.md
│   └── neo4j_lab_17_innovation_showcase.md
│
├── presentations/                       # All 3 presentation files
│   ├── neo4j_day1_presentation.html
│   ├── neo4j_day_2_presentation.html
│   └── neo4j_day3_presentation.html
│
├── testscripts/                         # Comprehensive test suite
│   ├── conftest.py
│   ├── test_lab_01_setup.py
│   ├── test_lab_02_cypher_fundamentals.py
│   ├── [... 15 more test files ...]
│   ├── test_runner.py
│   ├── run_tests.sh
│   ├── run_tests.bat
│   ├── requirements.txt
│   └── README.md
│
├── data/                                # Data reload scripts
│   ├── lab_01_data_reload.cypher
│   ├── lab_02_data_reload.cypher
│   ├── lab_03_data_reload.cypher
│   ├── lab_04_data_reload.cypher
│   ├── lab_05_data_reload.cypher
│   ├── lab_06_data_reload.cypher
│   ├── lab_07_data_reload.cypher
│   └── lab_08_data_reload.cypher
│
├── insurance/                           # Insurance database scripts
│   ├── insurance_db_script.txt
│   ├── business_management_queries.txt
│   ├── customer_visual_query.txt
│   └── insurance_visual_queries.txt
│
├── scripts/                             # Utility scripts
│   ├── start-neo4j.bat
│   ├── stop-neo4j.bat
│   ├── cleanup-neo4j.bat
│   └── update_course.bat
│
├── Documentation (root level)
│   ├── course_flow.md
│   ├── neo4j_3day_course_outline.md
│   ├── neo4j_course_flow.md
│   ├── neo4j_query_structure_guide.md
│   ├── neo4j_node_types_summary.md
│   ├── neo4j_enterprise_architecture.md
│   ├── neo4j_clustering_replication.md
│   ├── python_env.md
│   ├── setup.md
│   ├── updated_setup_md.md
│   └── STRUCTURE.md (this file)
│
└── README.md (root)

```

## 🗂️ Quick Access

### For Students

**Day 1:**
- Labs: `labs/neo4j_lab_1_*.md` through `labs/neo4j_lab_5_*.md`
- Presentation: `presentations/neo4j_day1_presentation.html`

**Day 2:**
- Labs: `labs/neo4j_lab_6_*.md` through `labs/neo4j_lab_11_*.md`
- Presentation: `presentations/neo4j_day_2_presentation.html`

**Day 3:**
- Labs: `labs/neo4j_lab_12.md` through `labs/neo4j_lab_17_*.md`
- Presentation: `presentations/neo4j_day3_presentation.html`

### For Instructors

**Setup:**
- Course overview: `course_flow.md`
- Environment setup: `python_env.md`, `setup.md`

**Teaching:**
- Open presentations from `presentations/` folder
- Reference labs from `labs/` folder
- Use data reload scripts for recovery: `data/lab_XX_data_reload.cypher`

**Validation:**
- Run tests: `cd testscripts && ./run_tests.sh`
- Check specific lab: `cd testscripts && pytest test_lab_XX_*.py -v`

## 📊 File Counts

- **Labs:** 17 files
- **Presentations:** 3 files
- **Test Files:** 17 test files + 6 supporting files
- **Data Reload Scripts:** 8 files
- **Documentation:** 13 files
- **Utility Scripts:** 4 files

**Total:** 78 files organized for easy navigation

## 🔍 Finding Files

### By Day
```bash
# Day 1 materials
ls labs/neo4j_lab_{1,2,3,4,5}_*.md
cat presentations/neo4j_day1_presentation.html

# Day 2 materials
ls labs/neo4j_lab_{6,7,8,9,10,11}_*.md
cat presentations/neo4j_day_2_presentation.html

# Day 3 materials
ls labs/neo4j_lab_{12,13,14,15,16,17}*.md
cat presentations/neo4j_day3_presentation.html
```

### By Topic
```bash
# Setup and fundamentals
ls labs/neo4j_lab_{1,2}_*.md

# Claims and financial
ls labs/neo4j_lab_3_claims_*.md

# Analytics
ls labs/neo4j_lab_{5,6,11}_*.md

# Python integration
ls labs/neo4j_lab_{12,13,14,15,16,17}.md

# Testing
ls testscripts/test_lab_*.py
```

## 🚀 Quick Start Paths

1. **Start teaching:** `presentations/neo4j_day1_presentation.html`
2. **Student lab:** `labs/neo4j_lab_1_enterprise_setup.md`
3. **Test validation:** `testscripts/run_tests.sh`
4. **Course overview:** `course_flow.md`
5. **Python setup:** `python_env.md`

---

**Last Updated:** 2025-10-18
**Course Version:** 1.0
