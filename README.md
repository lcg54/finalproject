# ERP Management System for Small Franchise Businesses

## Overview

본 프로젝트는 **중소 프랜차이즈 업체의 주문·재고·발주·출고·정산 흐름을 통합 관리하기 위한 ERP 시스템**입니다.  
단순 기능 구현을 넘어, 실제 프랜차이즈 운영 환경을 가정하여 
**업무 주체 분리(소비자·지점·본사), 도메인 책임 분리, 인프라 전환 가능성**을 고려하여 설계하였습니다.

프로젝트 전반은 다음과 같은 기준을 중심으로 구성되었습니다.

- 재고 수량을 직접 저장하지 않고, **모든 재고 변화를 이벤트 로그로만 기록**하여 데이터 정합성 및 추적 용이성 확보
- 트랜잭션 특성과 책임 범위에 따라 키오스크(소비자) 주문 도메인과 관리자(ERP) 업무 도메인을 분리
- 인증 및 세션 상태를 애플리케이션 외부(Redis)로 분리
- 개발 환경과 운영 환경 간 구조 차이를 최소화한 배포 구성

---

## For Contributors (Team Onboarding)

본 프로젝트는 도메인 분리, 인증 방식, 재고 관리 규칙 등 반드시 지켜야 할 설계 원칙을 포함하고 있습니다.

개발에 참여하기 전, 아래 문서를 먼저 확인하세요.

- [Project Onboarding Summary](docs/ONBOARDING.md)

---

## Tech Stack

| Category              | Technology                                   |
|-----------------------|-----------------------------------------------|
| Frontend              | React                                         |
| Backend               | Spring Boot / Django                          |
| Reverse Proxy         | Nginx                                         |
| Database              | MySQL                                         |
| Cache / Session Store | Redis                                         |
| Containerization      | Docker / Docker Compose                       |
| Cloud Provider        | AWS (EC2, ALB, RDS, ElastiCache) / Terraform  |

---

## Architecture

### Common Architecture Principles

- Nginx를 시스템의 단일 진입점으로 사용하여 정적 리소스와 API 트래픽을 라우팅
- Redis를 인증 및 세션 상태 저장소로 사용하여 애플리케이션의 Stateless 구조 유지
- 모든 서비스는 Docker 기반으로 구성되며, 설정은 환경 변수(`.env`)로만 관리
- Spring Boot와 Django는 트래픽 특성과 책임 범위에 따라 독립적으로 배포 가능하도록 구성

### Development Environment

```text
Kiosk
↓
Nginx (Gateway :8888)
├─ /                → React (Kiosk UI)
├─ /api             → Spring Boot
└─ admin.localhost  → Django (Gunicorn WSGI)
↓
Redis
↓
MySQL
```

- Docker Compose 기반 단일 호스트 환경
- 도메인 및 포트 분리로 운영 환경과 유사한 접근 경로 구성
- Django는 Gunicorn 기반으로 실행
- 로컬 개발을 위한 DB 초기화 스크립트(`init.sql`) 제공

### Production Environment

```text
Kiosk (your-domain.shop)
↓
AWS ALB (HTTPS :443)
↓
Nginx (EC2, Gateway)
├─ your-domain.shop/        → React
├─ your-domain.shop/api     → Spring Boot
└─ admin.your-domain.shop   → Django
↓
AWS ElastiCache (Redis)
↓
AWS RDS (MySQL)
```

- ALB를 통한 HTTPS 종료 및 외부 트래픽 분산 처리
- Backend 서비스는 Private Network 내에서만 접근 가능
- Redis와 MySQL은 관리형 서비스(RDS, ElastiCache) 사용
- 모든 인프라는 Terraform으로 관리

---

## Directory Structure

```text
finalproject/
├─ frontend/                # React Application (Kiosk UI)
├─ backend/                 # Spring Boot (Order / Payment Domain)
├─ admin/                   # Django (ERP Domain: Store + HQ)
├─ mysql/
│ └─ init/                  # Local DB initialization
├─ terraform/               # AWS Infrastructure as Code
├─ nginx/
│ └─ default.conf           # Nginx Gateway Configuration
├─ Dockerfile               # Nginx Gateway Dockerfile
├─ docker-compose.yml
├─ .env.development.example
├─ .env.production.example
├─ docs/
└─ README.md
```

---

## Design Decisions

### Domain-Based Backend Separation

- Spring Boot와 Django를 독립 서비스로 구성하여 도메인 간 결합 최소화

- Spring Boot
  - 키오스크 주문 및 결제
  - 주문 단위 출고 상태 관리
  - 고트래픽·고동시성을 고려한 트랜잭션 처리

- Django
  - 상품, 재고, 발주, 입고, 직원관리 등 운영 기능
  - 소속(Store/HQ) 및 권한(Role)에 따라 기능과 조회 범위 분리
  - 관리자 전용 UI 제공 (Django Admin)

### InventoryLog as Single Source of Truth

- 재고 수량을 별도 컬럼으로 관리하지 않음
- 모든 재고 변화는 InventoryLog 단일 테이블에 이벤트 단위로 기록
- 수정/삭제 불가 정책으로 과거 상태 추적 및 감사 가능

### Authentication & Session Strategy

- API 인증은 JWT 기반 Stateless 구조로 설계
- Refresh Token 및 Django Session은 Redis에 저장

### Development & Production Environment Control

- Docker Compose 기반의 통일된 개발 환경 구성
- 설정은 환경 변수로만 관리하여 개발/운영 환경 전환 시 코드 수정 불필요
- Terraform을 통해 AWS 인프라를 코드로 관리하여 환경 간 일관성 확보

---

## How to Run

아래 가이드를 참고하여 실행하세요.

- [로컬 개발 환경 실행 방법](docs/LOCAL_SETUP.md)
- [운영 환경 배포 방법](docs/PRODUCTION_SETUP.md)

---

## Application Features

### Kiosk (Spring Boot)

- 주문 생성
- 결제 처리
- 주문 기반 출고 상태 관리

### Admin (Django)

- 본사
  - 상품 / 거래처 / 창고 관리
  - 발주 및 입고 처리
- 지점
  - 재고 조정, 반품, 폐기
- 재고 이동 이력(InventoryLog) 조회
- 매출 조회 (Spring 계산 결과)

---

## Documentation

### API

- [API 명세서](docs/SwaggerUI.yaml)
- 관리자 기능은 Django Admin 기반으로 제공

### Database

- [ERD 이미지](docs/ERD.png)
- [ERD 상세 설명](docs/ERD.md)

---

## Future Improvements

- 재고 이벤트 기반 비동기 처리 (Outbound, Return 등)
- Spring ↔ Django 간 이벤트 기반 연동 구조 도입 (Kafka, Redis Stream)
- CI/CD 파이프라인 구성 (GitHub Actions, Jenkins)
- 모니터링 도구 도입 (Prometheus, Grafana)
- ECS(Fargate) 전환

---

## Summary

본 프로젝트는 소비자 주문(키오스크)과 운영 관리(ERP)를 분리한
중소 프랜차이즈 환경을 가정한 ERP 시스템입니다.

재고는 이벤트 로그(InventoryLog)를 단일 진실 소스로 관리하며,
주문 트래픽과 관리자 업무가 서로 간섭하지 않도록 설계되었습니다.

개발 환경과 운영 환경은 동일한 구조를 유지하도록 구성되어,
환경 전환 시 애플리케이션 코드 수정 없이 배포가 가능합니다.