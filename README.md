# ERP Management System for Distributors

## Overview

본 프로젝트는 **중소 유통업체의 주문·재고·발주·출고·정산 흐름을 통합 관리하는 ERP 시스템**을 구현한 웹 애플리케이션입니다.  
단순 기능 구현을 넘어, 실무 환경을 가정한 풀스택 서비스 아키텍처 설계 및 구현에 중점을 두었습니다.

특히 본 프로젝트는 다음과 같은 설계 원칙을 중심으로 구성되었습니다.

- **재고 상태를 직접 저장하지 않으며, 모든 재고 변화를 이벤트 로그로만 기록**하여 데이터 정합성과 추적 가능성을 우선시한 ERP 구조 구현
- 트랜잭션 밀도와 책임 범위에 따라 **B2C 판매 도메인과 B2B/관리자 업무 도메인을 분리**하여 구성
- Docker compose를 통해 **개발 환경의 구조적 일관성** 및 **운영 환경으로의 전환 용이성**을 고려
- Terraform을 통해 네트워크, EC2, ALB, RDS 리소스를 코드로 관리하여 **인프라 변경 이력을 코드 단위로 추적 가능**하도록 구성

---

## Tech Stack

- Frontend: *React*
- Backend: *Spring Boot / Django*
- Reverse Proxy / Load Balancer: *Nginx*
- Database: *MySQL*
- Containerization: *Docker / Docker Compose*
- Cloud Provider: *AWS / Terraform*

---

## Architecture

### 1. Development Environment

```text
Client
↓
Nginx (Gateway :8888)
├─ /        → React (Static Files)
├─ /api     → Spring Boot (B2C / Sales Domain)
└─ /admin   → Django (ERP / Admin Domain, Gunicorn WSGI)
↓
MySQL
```

- Nginx는 시스템의 단일 진입점으로 동작하며, 정적 리소스 서빙과 API/관리자 서비스에 대한 Reverse Proxy를 담당
- Spring Boot와 Django로 **트래픽 특성과 책임이 다른 도메인을 분리**하여 독립적인 서비스로 구성
- Django Admin은 역할과 운영 환경 전환을 고려하여 개발용 서버(runserver)가 아닌 **WSGI 서버(gunicorn) 기반**으로 실행
- 모든 서비스는 Docker 기반으로 구성되며, 환경 변수(`.env`)를 통해 설정 관리

### 2. Production Environment

```text
Client (your-domain.shop)
↓
AWS ALB (HTTPS :443)
↓
Nginx (EC2, Gateway)
├─ /        → React (Static Files)
├─ /api     → Spring Boot
└─ /admin   → Django
↓
AWS RDS (MySQL)
```

- AWS ALB가 외부 트래픽에 대한 Load Balancing 및 HTTPS 종료를 담당
- Backend(Spring Boot, Django)는 Private Network 내에서만 접근 가능
- Docker 환경 변수 구조를 그대로 유지하여 **개발·운영 환경 간 전환 용이**
- Terraform 기반 인프라 관리로 **환경 간 일관성 확보**
- Nginx 및 Application Container는 EC2 상에서 Docker로 실행

---

## Directory Structure

```text
finalproject/
├─ frontend/                # React Application (Build Output → Nginx Static Files)
├─ backend/                 # Spring Boot API Server (B2C / Sales Domain)
├─ admin/                   # Django Project (ERP / Admin)
├─ mysql/
│ └─ init/                  # DB & User initialization script
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

### 1. Domain-Based Backend Separation

- Spring Boot
  - 주문, 결제, 출고 등 소비자 중심 도메인
  - 고트래픽·고동시성 처리 고려
  - 주문/결제/출고 단계별 트랜잭션 경계 분리
  - 외부 결제 시스템 연동 및 실패/재시도를 고려한 트랜잭션 경계 설정

- Django
  - 발주, 입고, 재고, 거래처 관리 등 관리자 중심 도메인
  - 낮은 트래픽, CRUD 중심의 ERP 흐름
  - Django Admin을 활용하여 빠르게 관리 UI 구성
  - 관리자 전용 서비스로 외부 사용자 노출 없음
  - 관리자는 ‘사용자’가 아닌 ‘업무 주체’로 가정하여 UI보다 데이터 정확성을 우선

### 2. InventoryLog as Single Source of Truth

- 재고 수량을 별도 컬럼으로 관리하지 않음
- 모든 재고 변화는 InventoryLog 단일 테이블에 **이벤트 단위로 기록**
- 재고는 누적 로그 기반으로 계산 가능
- 수정/삭제 불가 정책으로 **과거 상태 추적 및 감사(Audit) 가능**

### 3. Database & Account Separation

- Spring Boot / Django 간 DB 계정 분리
- 최소 권한 원칙 적용
- 장애 및 보안 이슈 발생 시 영향 범위 최소화

### 4. Development & Production Environment Control

- Docker Compose 기반 통일된 로컬 개발 환경 구성
- 해당 구조는 개발/운영 환경에서 동일하게 유지
- 운영 환경 전환은 **`.env` 파일 교체만으로 가능**
- Terraform 기반 AWS 인프라 구축

---

## How to Run

본 프로젝트는 로컬 개발 환경과 운영 환경을 분리하여 실행할 수 있도록 구성되어 있습니다.  
환경에 따라 아래 가이드를 참고하여 실행하세요.

- [로컬 개발 환경 실행 방법](docs/LOCAL_SETUP.md)
- [운영 환경 배포 방법](docs/PRODUCTION_SETUP.md)

---

## Application Features

### 1. Consumer (Spring Boot)

- 회원 가입 / 로그인
- JWT 기반 인증
- 주문 생성
- 결제 처리
- 출고 요청 및 상태 관리

### 2. Admin (Django)

- 상품 / 거래처 / 창고 관리
- 발주(Purchase Order) 관리
- 입고(Inbound) 처리
- 재고 조정 / 반품 / 폐기
- 재고 이동 이력(InventoryLog) 조회
- 매출 집계 데이터 조회 (Spring 계산 결과)

---

## API Documentation

- [API 명세서](docs/SwaggerUI.yaml)
- 관리자 기능은 Django Admin 기반으로 제공

---

## Database Documentation

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

주문·결제·출고와 같은 고트래픽 트랜잭션과 발주·입고·재고 관리와 같은 관리자 업무를 분리하여, 
각 도메인이 자신의 책임과 트랜잭션 특성에 집중할 수 있도록 설계하였습니다.

Docker Compose와 Terraform을 활용하여, 
개발 환경부터 AWS 기반 운영 환경까지 일관된 구조로 확장 가능하도록 구성하였습니다.

본 프로젝트는 단순 구현이 아닌, 
실무에서 ‘왜 이렇게 설계했는지’를 설명할 수 있는 구조를 목표로 합니다.