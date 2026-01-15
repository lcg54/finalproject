# ERD Configuration

본 문서는 **중소 프랜차이즈 키오스크 기반 ERP 시스템**의 데이터 모델을 정의합니다.

본 시스템의 핵심 설계 원칙은 다음과 같습니다.

- 주문·결제·출고 등 트랜잭션 중심 도메인과 관리자(ERP) 도메인의 분리
- 재고 수량을 직접 저장하지 않고, 모든 재고 변화는 `InventoryLog`를 통해 기록
- 지점 → 본사 업무 흐름은 요청(Request) + 상태(State) 기반으로 관리
- 매출 집계는 배치 기반으로 생성된 파생 데이터로 관리

---

## 1. Master Data

### Organization
본사(HQ) 및 지점(Store)을 통합 표현하는 엔티티

| Field | Type | Description |
|---|---|---|
| id | PK | 조직 ID |
| type | ENUM(HQ, Store) | 조직 유형 |
| name | VARCHAR | 조직명 |
| status | ENUM(ACTIVE, INACTIVE) | 운영 상태 |
| created_at | DATETIME | 생성 시각 |
| updated_at | DATETIME | 수정 시각 |

---

### Kiosk
소비자 주문 및 결제를 수행하는 지점 소속 단말

| Field | Type | Description |
|---|---|---|
| id | PK | 키오스크 ID |
| store_id | FK → Organization.id | 소속 지점 |
| identifier | VARCHAR | 단말 식별자 |
| status | ENUM(ACTIVE, INACTIVE) | 사용 상태 |
| last_seen_at | DATETIME | 마지막 접속 시각 |

---

### Product

| Field | Type | Description |
|---|---|---|
| id | PK | 상품 ID |
| sku | VARCHAR | 상품 코드 |
| name | VARCHAR | 상품명 |
| category | ENUM | 카테고리 |
| description | VARCHAR | 상품 설명 |
| image | VARCHAR | 상품 이미지 |
| price | DECIMAL | 소비자 판매가 |
| status | ENUM(ON_SALE, DISCONTINUED) | 판매 상태 |
| created_at | DATETIME | 생성 시각 |

---

### Warehouse
본사 또는 지점 소속 창고

| Field | Type | Description |
|---|---|---|
| id | PK | 창고 ID |
| organization_id | FK → Organization.id | 소속 조직 |
| name | VARCHAR | 창고명 |
| type | ENUM(HQ, Store) | 창고 유형 |

---

### Supplier

| Field | Type | Description |
|---|---|---|
| id | PK | 거래처 ID |
| name | VARCHAR | 거래처명 |
| contact | VARCHAR | 연락처 |
| status | ENUM(ACTIVE, INACTIVE) | 거래 상태 |

---

## 2. Store Operations

### Order
소비자 주문

| Field | Type | Description |
|---|---|---|
| id | PK | 주문 ID |
| kiosk_id | FK → Kiosk.id | 주문 발생 단말 |
| store_id | FK → Organization.id | 지점 |
| status | ENUM(CREATED, PAID, CANCELED) | 주문 상태 |
| ordered_at | DATETIME | 주문 시각 |

---

### OrderItem

| Field | Type | Description |
|---|---|---|
| id | PK | 주문 항목 ID |
| order_id | FK → Order.id | 주문 |
| product_id | FK → Product.id | 상품 |
| quantity | INT | 수량 |
| unit_price | DECIMAL | 단가 |

---

### Outbound (Store)
소비자 출고 처리

| Field | Type | Description |
|---|---|---|
| id | PK | 출고 ID |
| order_id | FK → Order.id | 주문 |
| warehouse_id | FK → Warehouse.id | 출고 창고 |
| status | ENUM(READY, COMPLETED) | 출고 상태 |
| outbound_at | DATETIME | 출고 시각 |

---

### StockRequest
지점 → 본사 보충 요청

| Field | Type | Description |
|---|---|---|
| id | PK | 요청 ID |
| store_id | FK → Organization.id | 요청 지점 |
| status | ENUM(REQUESTED, APPROVED, REJECTED, FULFILLED, CLOSED) | 처리 상태 |
| requested_at | DATETIME | 요청 시각 |
| decided_at | DATETIME | 승인/반려 시각 |

---

### StockRequestItem

| Field | Type | Description |
|---|---|---|
| id | PK | 요청 항목 ID |
| stock_request_id | FK → StockRequest.id | 요청 |
| product_id | FK → Product.id | 상품 |
| quantity | INT | 요청 수량 |

---

### Return / Scrap
반품 및 폐기 (구조 동일)

| Field | Type | Description |
|---|---|---|
| id | PK | 처리 ID |
| store_id | FK → Organization.id | 지점 |
| product_id | FK → Product.id | 상품 |
| quantity | INT | 수량 |
| reason | VARCHAR | 사유 |
| processed_at | DATETIME | 처리 시각 |

---

## 3. Headquarters Operations

### PurchaseOrder
본사 → 거래처 발주

| Field | Type | Description |
|---|---|---|
| id | PK | 발주 ID |
| supplier_id | FK → Supplier.id | 거래처 |
| status | ENUM(CREATED, SENT, RECEIVED, CLOSED) | 발주 상태 |
| ordered_at | DATETIME | 발주 시각 |

---

### PurchaseOrderItem

| Field | Type | Description |
|---|---|---|
| id | PK | 발주 항목 ID |
| purchase_order_id | FK → PurchaseOrder.id | 발주 |
| product_id | FK → Product.id | 상품 |
| quantity | INT | 수량 |
| unit_cost | DECIMAL | 원가 |

---

### Inbound / InboundShipment

| Field | Type | Description |
|---|---|---|
| id | PK | 입고 ID |
| purchase_order_id | FK → PurchaseOrder.id | 발주 |
| warehouse_id | FK → Warehouse.id | 입고 창고 |
| inbound_at | DATETIME | 입고 시각 |

---

### Outbound (HQ)
본사 → 지점 출고

| Field | Type | Description |
|---|---|---|
| id | PK | 출고 ID |
| stock_request_id | FK → StockRequest.id | 연관 요청 |
| warehouse_id | FK → Warehouse.id | 출고 창고 |
| status | ENUM(READY, SHIPPED, COMPLETED) | 상태 |
| outbound_at | DATETIME | 출고 시각 |

---

### InventoryAdjustment

| Field | Type | Description |
|---|---|---|
| id | PK | 조정 ID |
| warehouse_id | FK → Warehouse.id | 대상 창고 |
| product_id | FK → Product.id | 상품 |
| quantity | INT | 증감 수량 |
| reason | VARCHAR | 사유 |
| adjusted_at | DATETIME | 조정 시각 |

---

## 4. Analytics

### SalesSummary
배치 집계 매출 데이터

| Field | Type | Description |
|---|---|---|
| id | PK | 집계 ID |
| organization_id | FK → Organization.id | 본사 또는 지점 |
| date | DATE | 집계 일자 |
| total_sales | DECIMAL | 총 매출 |
| total_orders | INT | 주문 수 |

---

## 5. Inventory - Single Source of Truth

### InventoryLog
모든 재고 변화의 단일 진실 소스

| Field | Type | Description |
|---|---|---|
| id | PK | 로그 ID |
| product_id | FK → Product.id | 상품 |
| warehouse_id | FK → Warehouse.id | 창고 |
| change_qty | INT | 증감 수량 (+/-) |
| source_type | VARCHAR | 발생 원천 (ORDER, INBOUND, RETURN 등) |
| source_id | BIGINT | 원천 ID |
| occurred_at | DATETIME | 발생 시각 |

---

## 6. Notes

- 모든 재고 수량은 `InventoryLog` 집계를 통해 계산된다.
- `SalesSummary`는 원천 데이터가 아니며 재생성 가능하다.
- Spring Boot는 Order, Outbound, 매출 원천 데이터 생성 책임을 가진다.
- Django는 요청, 발주, 입고, 재고 관리 및 집계 조회 책임을 가진다.

