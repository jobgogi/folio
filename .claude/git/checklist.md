# Git 체크리스트

## 커밋 전
- [ ] 전체 테스트 통과
- [ ] 작업 범위 외 파일 없음
- [ ] 디버그 코드 제거
- [ ] 커밋 메시지 컨벤션 준수

## 커밋 메시지 컨벤션
test(scope):     테스트 추가/수정
feat(scope):     기능 구현
fix(scope):      버그 수정
refactor(scope): 리팩터링
chore(scope):    설정, 패키지

예)
test(file-detector): PDF/ePub 타입 감지 테스트 추가
feat(file-detector): MIME 타입 기반 파일 감지 구현
chore(melos): 모노레포 초기 설정

## PR 전
- [ ] 전체 테스트 통과
- [ ] feature 브랜치 push 완료
- [ ] PR 생성 완료
- [ ] Claude Code 중단 (머지는 GitHub에서)

## 절대 금지
- git merge 직접 실행
- git push origin main / develop