# ERP Management System for Small Franchise Businesses

## Overview

본 프로젝트는 **중소 프랜차이즈 업체의 주문·재고·발주·출고·정산 흐름을 통합 관리하는 ERP 시스템**을 구현한 웹 애플리케이션입니다. 
단순 기능 구현을 넘어, 실무 환경을 가정한 **도메인 분리, 인증 책임 분리, 인프라 전환 가능성**을 고려한 풀스택 아키텍처 설계에 중점을 두었습니다.

특히 본 프로젝트는 다음과 같은 설계 원칙을 중심으로 구성되었습니다.

- **재고 상태를 직접 저장하지 않으며, 모든 재고 변화를 이벤트 로그로만 기록**하여 데이터 정합성과 추적 가능성을 우선시한 ERP 구조 구현
- 트랜잭션 밀도와 책임 범위에 따라 **키오스크 주문 도메인과 관리자(ERP) 업무 도메인을 분리**
- JWT 및 Redis를 활용하여 **인증 및 상태 관리 책임을 애플리케이션 외부로 분리**
- Docker Compose와 Terraform을 활용하여 **개발 환경과 운영 환경 간 구조적 일관성 및 전환 용이성 확보**

---

## For Contributors (Team Onboarding)

이 프로젝트는 도메인 분리, 인증 방식, 재고 관리 규칙 등 구조적으로 반드시 지켜야 할 설계 원칙을 포함하고 있습니다.

개발에 참여하기 전, 아래 문서를 먼저 확인하세요.

- [Project Onboarding Summary](docs/ONBOARDING.md)

이 문서는 각 서비스의 책임 범위와 개발 시 반드시 지켜야 할 규칙을 요약합니다.

---

## Tech Stack

- Frontend: *React*
- Backend: *Spring Boot / Django*
- Reverse Proxy: *Nginx*
- Database: *MySQL*
- Cache / Session Store: *Redis*
- Containerization: *Docker / Docker Compose*
- Cloud Provider: *AWS (EC2, ALB, RDS, ElastiCache) / Terraform*

---

## Architecture

### Common Architecture Principles

- Nginx는 시스템의 단일 진입점(Single Entry Point)으로 동작하며,
  정적 리소스 서빙과 API/관리자 서비스에 대한 Reverse Proxy 역할을 수행
- Redis는 인증 및 세션 관련 상태를 중앙에서 관리하여,
  애플리케이션 레이어의 Stateless 구성을 유지
- 모든 서비스는 Docker 기반으로 구성되며,
  설정은 환경 변수(`.env`)로만 관리하여 코드 수정 없이 환경 전환 가능
- 백엔드 서비스(Spring Boot, Django)는
  트래픽 특성과 책임 범위에 따라 독립적으로 배포 및 확장 가능하도록 구성

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

- Docker Compose 기반의 로컬 개발 환경으로, 모든 서비스는 단일 호스트에서 실행
- 도메인 및 포트 분리를 통해 운영 환경과 최대한 유사한 접근 경로 유지
- Django Admin은 개발 서버(runserver)가 아닌 Gunicorn WSGI 기반으로 실행하여 운영 환경과의 실행 차이를 최소화
- 초기 개발 및 테스트를 위한 DB 초기화 스크립트 제공 (mysql/init)

### Production Environment

```text
Client (your-domain.shop)
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

- AWS ALB를 통해 HTTPS 종료 및 외부 트래픽 분산 처리
- Backend(Spring Boot, Django)는 Private Network 내에서만 접근 가능하도록 구성
- 상태 저장이 필요한 인프라(Redis, MySQL)는 관리형 서비스(RDS, ElastiCache)로 분리
- 개발 환경과 동일한 컨테이너 구조 및 환경 변수 체계를 유지하여 환경 간 전환 시 애플리케이션 코드 수정 없이 배포 가능
- 모든 인프라는 Terraform으로 관리하여 재현 가능성과 환경 간 일관성 확보

---

## Directory Structure

```text
finalproject/
├─ frontend/                # React Application (Build Output → Nginx Static Files)
├─ backend/                 # Spring Boot API Server (Kiosk / Order Domain)
├─ admin/                   # Django Project (ERP / Admin Domain)
├─ mysql/
│ └─ init/                  # DB & User initialization script (only for local)
├─ terraform/               # AWS Infrastructure as Code (EC2, ALB, RDS, ElastiCache)
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

- Spring Boot와 Django는 독립적인 서비스로 배포되어, 특정 도메인 장애가 전체 시스템으로 전파되지 않도록 구성

- Spring Boot
  - 키오스크 주문, 결제, 출고 등 **트랜잭션 중심 도메인**
  - 고트래픽·고동시성 처리 고려
  - 단말 단위 요청을 전제로 한 인증 및 트랜잭션 처리 구조
  - 외부 결제 시스템 연동 및 실패/재시도를 고려한 트랜잭션 경계 설정

- Django
  - 발주, 입고, 재고, 거래처 관리 등 **관리자 중심 도메인**
  - Django Admin을 활용하여 빠르게 관리 UI 구성
  - 외부 사용자 노출 없는 관리자 전용 서비스

### InventoryLog as Single Source of Truth

- 재고 수량을 별도 컬럼으로 관리하지 않음
- 모든 재고 변화는 InventoryLog 단일 테이블에 이벤트 단위로 기록
- 수정/삭제 불가 정책으로 **과거 상태 추적 및 감사(Audit) 가능**

### Authentication & Session Strategy

- API 인증은 JWT 기반 Stateless 구조로 설계
- Refresh Token은 Redis에 저장하여 다음 요구사항 충족
  - 토큰 탈취 시 강제 무효화 가능
  - 토큰 수명 및 재발급 정책 중앙 관리
- Django Admin은 기존 Session 인증을 유지하되, 세션 저장소를 Redis로 분리하여 DB 부하 최소화

### Development & Production Environment Control

- Docker Compose 기반의 통일된 개발 환경 구성
- 설정은 환경 변수로만 관리하여 개발/운영 환경 전환 시 코드 수정 없음
- Terraform을 통해 AWS 인프라를 코드로 관리하여 환경 간 일관성 확보

---

## How to Run

본 프로젝트는 로컬 개발 환경과 운영 환경을 분리하여 실행할 수 있도록 구성되어 있습니다.  
환경에 따라 아래 가이드를 참고하여 실행하세요.

- [로컬 개발 환경 실행 방법](docs/LOCAL_SETUP.md)
- [운영 환경 배포 방법](docs/PRODUCTION_SETUP.md)

---

## Application Features

### Kiosk (Spring Boot)

- 키오스크 단말 등록 및 운영 관리
- 주문 생성
- 결제 처리
- 출고 요청 및 상태 관리

### Admin (Django)

- 상품 / 거래처 / 창고 관리
- 발주(Purchase Order) 관리
- 입고(Inbound) 처리
- 재고 조정 / 반품 / 폐기
- 재고 이동 이력(InventoryLog) 조회
- 매출 집계 데이터 조회 (Spring 계산 결과)

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

- 재고 이벤트 기반 비동기 처리 구조 도입 (Outbound, Return 등)
- Spring ↔ Django 간 이벤트 기반 연동 (Kafka, Redis Stream)
- CI/CD 파이프라인 구축 (GitHub Actions, Jenkins)
- 모니터링 도구(Prometheus, Grafana) 도입 
- ECS(Fargate) 전환

---

## Summary

본 프로젝트는 재고를 단일 진실 소스로 설계하고, 
모든 재고 변화를 이벤트 로그로만 관리하는 ERP 시스템입니다.

주문·결제·출고와 같은 트랜잭션 처리는 키오스크 단말을 중심으로 처리되며, 
발주·입고·재고 관리와 같은 운영 업무는 관리자(ERP) 도메인으로 분리하여 
각 도메인이 자신의 책임과 트랜잭션 특성에 집중할 수 있도록 설계하였습니다.

JWT와 Redis를 활용하여 인증과 상태 관리 책임을 분리하고, 
Docker와 Terraform을 통해 개발 환경에서 AWS 운영 환경까지 
구조 변경 없이 확장 가능하도록 설계하였습니다.

본 프로젝트는 단순 구현이 아닌, 
실무 환경에서의 운영, 보안, 확장성을 설명할 수 있는 구조를 목표로 합니다.