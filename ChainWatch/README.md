# ChainWatch 📡

A decentralized smart contract surveillance and compliance monitoring platform built on the Stacks blockchain using Clarity smart contracts.

## Overview

ChainWatch enables qualified inspectors to register, conduct comprehensive compliance assessments of Clarity smart contracts, and have their work endorsed by authorized supervisors. The platform maintains a detailed database of compliance reports, violation assessments, and inspector credentials.

## Features

### 🔍 Contract Surveillance
- Submit detailed compliance assessments for any Clarity smart contract
- Track compliance ratings and detected violations
- Store evidence with cryptographic hash verification
- Maintain comprehensive surveillance history and timeline for each contract

### 👮‍♂️ Inspector Management
- Decentralized inspector registration system
- Reputation-based ranking and credibility tracking
- Supervisor endorsement system for report accuracy
- Active/inactive status management for inspectors

### ✅ Supervisor Endorsement System
- Expert supervisors validate report quality and accuracy
- Reputation score progression based on endorsed reports
- Self-endorsement prevention mechanisms
- Transparency and accountability features

### 📊 Analytics & Monitoring
- Contract-specific surveillance summaries
- Historical compliance rating tracking
- Inspector performance metrics
- Platform-wide surveillance statistics

## Smart Contract Structure

### Data Storage
- **compliance-reports**: Complete surveillance records with timestamps and compliance ratings
- **qualified-inspectors**: Inspector profiles with reputation scores and statistics  
- **contract-surveillance-logs**: Per-contract surveillance history and compliance data
- **compliance-supervisors**: Authorized expert supervisor addresses

### Key Functions

#### Public Functions
- `register-compliance-inspector()` - Register as a new compliance inspector
- `submit-surveillance-report()` - Submit compliance report for a contract
- `supervisor-approve-report()` - Supervisor endorsement of existing report
- `authorize-compliance-supervisor()` - Admin function to add supervisors
- `adjust-surveillance-fee()` - Admin function to update fees

#### Read-Only Functions
- `get-report-details()` - Retrieve specific surveillance report information
- `get-inspector-profile()` - View inspector statistics and reputation
- `get-contract-surveillance-summary()` - Contract's complete surveillance history
- `get-active-contract-surveillance()` - Most recent surveillance for a contract
- `get-total-surveillance-count()` - Platform surveillance statistics
- `get-current-surveillance-fee()` - Current fee for submitting reports

## Economic Model

- **Surveillance Fee**: 2.5 STX per report submission (configurable by admin)
- **Revenue Distribution**: Fees go to platform maintenance and development
- **Incentive Structure**: Reputation scores increase through successful supervisor endorsements

## Getting Started

### Prerequisites
- Stacks wallet with STX for transaction fees and surveillance submissions
- Understanding of Clarity smart contract compliance principles

### For Inspectors
1. Call `register-compliance-inspector()` to join the platform
2. Conduct compliance analysis of target contracts
3. Submit reports using `submit-surveillance-report()` with:
   - Target contract principal
   - Compliance rating score (0-100, lower indicates more violations)
   - Number of violations found
   - IPFS hash of detailed evidence documentation

### For Supervisors
1. Must be authorized by platform controller
2. Review submitted reports for quality and accuracy
3. Cannot endorse own reports (enforced by contract)

### For Contract Developers
1. Use read-only functions to check compliance status of any contract
2. View historical compliance assessments
3. Track improvement over time through multiple surveillance reports

## Security Features

- **Access Controls**: Admin-only functions for critical operations
- **Self-Endorsement Prevention**: Inspectors cannot supervisor-approve their own work
- **Economic Deterrents**: Surveillance fees prevent spam submissions
- **Transparency**: All surveillance data publicly accessible on-chain
- **Immutability**: Compliance reports cannot be modified after submission
