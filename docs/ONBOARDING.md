# Project Onboarding Summary

*ERP Management System*

## 1. Project Goal (왜 이 구조인가)

- 본 프로젝트는 중소 유통업체의 주문–출고–재고–정산 흐름을 안정적으로 관리하는 ERP 시스템을 목표로 합니다.
- 소비자 트래픽과 관리자 업무를 분리하여 트랜잭션 특성과 장애 영향 범위를 명확히 나누는 구조로 설계되었습니다.

## 2. Service Responsibility (가장 중요)

### Spring Boot (B2C / Sales Domain)

- 소비자 대상 API 전용
- 담당 영역
  - 주문, 결제, 출고 요청
  - 외부 결제 시스템 연동
- 특징
  - 고트래픽·동시성 고려
  - API 기반 서비스
- **관리자용 기능 구현 금지**

---

### Django (ERP / Admin Domain)

- 내부 관리자 전용 서비스
- 담당 영역
  - 발주, 입고, 재고, 거래처 관리
  - 재고 이력(InventoryLog) 관리
- 특징
  - Django Admin 중심
  - 외부 사용자 직접 접근 없음
- **소비자 트래픽 처리 금지**

## 3. Authentication & State Management

### 공통 원칙

- API 인증은 **JWT 기반 Stateless** 구조
- 서버 메모리에 인증 상태를 저장하지 않음

### Redis 사용 규칙

- Redis는 **상태 저장 전용 인프라**
  - Refresh Token 저장
  - Django Session Store
- 비즈니스 데이터 저장 용도로 사용하지 않음

## 4. Inventory Design Rule (절대 규칙)

- 재고 수량을 직접 저장하지 않음
- 모든 재고 변화는 **InventoryLog 이벤트로만 기록**
- 로그는 수정/삭제 불가

→ 재고 수량이 필요하면 **“현재 재고 = InventoryLog 누적 결과”** 로 계산

## 5. Environment & Configuration

- 모든 서비스는 Docker 기반으로 실행
- 개발/운영 환경 차이는 **인프라 위치뿐**
- 설정 변경은 `.env` 교체로만 처리
- 애플리케이션 코드는 환경(Local / AWS)을 인지하지 않음

## 6. What You Should / Should Not Do

### You Should

- 자신의 도메인(Spring / Django)에만 집중
- 공통 규칙(인증, 재고 설계) 유지
- Redis는 인증/세션 용도로만 사용

### You Should NOT

- Spring에 관리자 기능 추가
- Django에서 소비자 API 구현
- 재고 수량 컬럼 추가
- 서버 메모리에 상태 저장