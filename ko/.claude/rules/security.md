# 보안 규칙 (CRITICAL)

## 커밋 전 체크리스트

모든 커밋 전 반드시 확인:
- [ ] 하드코딩된 시크릿 없음 (API 키, 비밀번호, 토큰)
- [ ] 모든 사용자 입력 검증됨
- [ ] API 엔드포인트 입력 새니타이징
- [ ] 에러 메시지에 민감 정보 미포함

## 시크릿 관리

```kotlin
// NEVER: 하드코딩
val apiKey = "sk-proj-xxxxx"

// ALWAYS: 환경변수
val apiKey = System.getenv("API_KEY")
    ?: throw IllegalStateException("API_KEY not configured")
```

## 리뷰 체크리스트 (우선순위별)

### CRITICAL
- 하드코딩된 인증 정보
- 스토리지 인젝션 위험
- 입력값 검증 누락
- 인증/인가 문제

### HIGH
- 에러 처리에서 민감 정보 노출
- 로그에 시크릿 기록
- 의존성 취약점

### MEDIUM
- CORS 설정
- Rate limiting
- 세션 관리

## 보안 이슈 발견 시

1. 즉시 중단
2. CRITICAL 이슈 먼저 수정
3. 노출된 시크릿 로테이션
4. 코드베이스 전체에서 유사 이슈 확인
