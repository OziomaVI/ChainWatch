;; ChainWatch - Smart Contract Surveillance and Compliance Platform
;; A decentralized surveillance and compliance monitoring system for Clarity smart contracts

;; Constants
(define-constant PLATFORM_CONTROLLER tx-sender)
(define-constant ERR_FORBIDDEN (err u400))
(define-constant ERR_RESOURCE_MISSING (err u401))
(define-constant ERR_INSPECTOR_ACTIVE (err u402))
(define-constant ERR_UNQUALIFIED_INSPECTOR (err u403))

;; Data Variables
(define-data-var surveillance-counter uint u0)
(define-data-var surveillance-fee uint u2500000) ;; 2.5 STX in microSTX

;; Data Maps
(define-map compliance-reports
    { report-id: uint }
    {
        monitored-contract: principal,
        surveillance-officer: principal,
        report-height: uint,
        compliance-rating: uint,
        violations-found: uint,
        evidence-hash: (string-ascii 64),
        is-supervisor-approved: bool
    }
)

(define-map qualified-inspectors
    { inspector-wallet: principal }
    {
        reputation-score: uint,
        report-submissions: uint,
        endorsed-reports: uint,
        inspector-status: bool
    }
)

(define-map contract-surveillance-logs
    { monitored-contract: principal }
    {
        active-report-id: uint,
        total-reports: uint,
        top-compliance-rating: uint
    }
)

;; Authorization map for supervisors
(define-map compliance-supervisors principal bool)

;; Public Functions

;; Register a new compliance inspector
(define-public (register-compliance-inspector)
    (let ((caller tx-sender))
        (asserts! (is-none (map-get? qualified-inspectors { inspector-wallet: caller })) ERR_INSPECTOR_ACTIVE)
        (map-set qualified-inspectors 
            { inspector-wallet: caller }
            {
                reputation-score: u0,
                report-submissions: u0,
                endorsed-reports: u0,
                inspector-status: true
            }
        )
        (ok true)
    )
)

;; Submit a compliance surveillance report
(define-public (submit-surveillance-report (monitored-contract principal) (compliance-rating uint) (violations-found uint) (evidence-hash (string-ascii 64)))
    (let (
        (caller tx-sender)
        (new-report-id (+ (var-get surveillance-counter) u1))
        (inspector-record (unwrap! (map-get? qualified-inspectors { inspector-wallet: caller }) ERR_UNQUALIFIED_INSPECTOR))
    )
        ;; Ensure inspector is registered and active
        (asserts! (get inspector-status inspector-record) ERR_UNQUALIFIED_INSPECTOR)
        
        ;; Pay surveillance fee
        (try! (stx-transfer? (var-get surveillance-fee) caller PLATFORM_CONTROLLER))
        
        ;; Create compliance report
        (map-set compliance-reports
            { report-id: new-report-id }
            {
                monitored-contract: monitored-contract,
                surveillance-officer: caller,
                report-height: stacks-block-height,
                compliance-rating: compliance-rating,
                violations-found: violations-found,
                evidence-hash: evidence-hash,
                is-supervisor-approved: false
            }
        )
        
        ;; Update inspector statistics
        (map-set qualified-inspectors
            { inspector-wallet: caller }
            (merge inspector-record { report-submissions: (+ (get report-submissions inspector-record) u1) })
        )
        
        ;; Update contract surveillance tracking
        (let ((log-data (default-to 
                { active-report-id: u0, total-reports: u0, top-compliance-rating: u100 }
                (map-get? contract-surveillance-logs { monitored-contract: monitored-contract })
            )))
            (map-set contract-surveillance-logs
                { monitored-contract: monitored-contract }
                {
                    active-report-id: new-report-id,
                    total-reports: (+ (get total-reports log-data) u1),
                    top-compliance-rating: (if (< compliance-rating (get top-compliance-rating log-data)) 
                                   compliance-rating 
                                   (get top-compliance-rating log-data))
                }
            )
        )
        
        ;; Update surveillance counter
        (var-set surveillance-counter new-report-id)
        
        (ok new-report-id)
    )
)

;; Supervisor approval of compliance report (only supervisors can endorse others' work)
(define-public (supervisor-approve-report (report-id uint))
    (let (
        (caller tx-sender)
        (report-data (unwrap! (map-get? compliance-reports { report-id: report-id }) ERR_RESOURCE_MISSING))
        (original-inspector (get surveillance-officer report-data))
    )
        ;; Ensure caller is supervisor and not approving their own work
        (asserts! (default-to false (map-get? compliance-supervisors caller)) ERR_FORBIDDEN)
        (asserts! (not (is-eq caller original-inspector)) ERR_FORBIDDEN)
        
        ;; Mark report as supervisor approved
        (map-set compliance-reports
            { report-id: report-id }
            (merge report-data { is-supervisor-approved: true })
        )
        
        ;; Update original inspector's reputation
        (let ((inspector-record (unwrap! (map-get? qualified-inspectors { inspector-wallet: original-inspector }) ERR_RESOURCE_MISSING)))
            (map-set qualified-inspectors
                { inspector-wallet: original-inspector }
                (merge inspector-record { 
                    endorsed-reports: (+ (get endorsed-reports inspector-record) u1),
                    reputation-score: (+ (get reputation-score inspector-record) u25)
                })
            )
        )
        
        (ok true)
    )
)

;; Admin function to authorize compliance supervisors
(define-public (authorize-compliance-supervisor (supervisor principal))
    (begin
        (asserts! (is-eq tx-sender PLATFORM_CONTROLLER) ERR_FORBIDDEN)
        (map-set compliance-supervisors supervisor true)
        (ok true)
    )
)

;; Admin function to adjust surveillance fee
(define-public (adjust-surveillance-fee (updated-fee uint))
    (begin
        (asserts! (is-eq tx-sender PLATFORM_CONTROLLER) ERR_FORBIDDEN)
        (var-set surveillance-fee updated-fee)
        (ok true)
    )
)

;; Read-only Functions

;; Get compliance report details
(define-read-only (get-report-details (report-id uint))
    (map-get? compliance-reports { report-id: report-id })
)

;; Get inspector profile
(define-read-only (get-inspector-profile (inspector-wallet principal))
    (map-get? qualified-inspectors { inspector-wallet: inspector-wallet })
)

;; Get contract surveillance summary
(define-read-only (get-contract-surveillance-summary (monitored-contract principal))
    (map-get? contract-surveillance-logs { monitored-contract: monitored-contract })
)

;; Get active surveillance report for a contract
(define-read-only (get-active-contract-surveillance (monitored-contract principal))
    (let ((log-data (map-get? contract-surveillance-logs { monitored-contract: monitored-contract })))
        (match log-data
            summary (map-get? compliance-reports { report-id: (get active-report-id summary) })
            none
        )
    )
)

;; Get total surveillance report count
(define-read-only (get-total-surveillance-count)
    (var-get surveillance-counter)
)

;; Get current surveillance fee
(define-read-only (get-current-surveillance-fee)
    (var-get surveillance-fee)
)

;; Check if supervisor is authorized
(define-read-only (is-authorized-supervisor (supervisor principal))
    (default-to false (map-get? compliance-supervisors supervisor))
)