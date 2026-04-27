# 테스트 규칙

## 절대 금지 패턴
- expect(true).toBe(true)
- expect(result).toBe(result)       ← 구현을 기댓값으로 사용
- expect(result).toBeDefined()      ← 너무 느슨한 단언
- expect(result).toBeTruthy()       ← 너무 느슨한 단언
- 단언 없는 빈 테스트 블록
- 테스트 통과용 하드코딩 구현

## 좋은 테스트 조건
- 테스트 이름만 읽어도 동작을 알 수 있다
- 구체적인 입력값과 기댓값을 사용한다
- 실패 케이스를 반드시 포함한다
- 하나의 테스트는 하나의 동작만 검증한다

## Flutter 테스트 레벨
- Unit test    : 비즈니스 로직, 모델, 유틸
- Widget test  : UI 컴포넌트 동작
- Integration  : 화면 전체 흐름

## NestJS 테스트 레벨
- Unit test    : Service, 유틸
- e2e test     : API 엔드포인트