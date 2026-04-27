# CLAUDE.md

모든 규칙은 .claude/ 폴더에서 관리됩니다.
작업 시작 전 반드시 아래 순서로 읽으세요.

## 필수 읽기 순서
1. .claude/project.md          프로젝트 개요 및 명령어
2. .claude/git/strategy.md     브랜치 전략 및 PR 규칙
3. .claude/git/checklist.md    커밋/PR 전 체크리스트
4. .claude/workflow.md         개발 워크플로우
5. .claude/test/rules.md       테스트 품질 규칙
6. .claude/test/patterns.md    테스트 작성 패턴
7. .claude/test/checklist.md   구현 전 체크리스트
8. .claude/rules/flutter.md    Flutter 코딩 규칙
9. .claude/rules/nestjs.md     NestJS 코딩 규칙

## 현재 작업 Phase
.claude/phases/phase1.md 참고

## 작업 흐름 요약
develop 최신화
→ feature 브랜치 생성
→ 테스트 작성 (Red 확인 필수)
→ 구현 (Green)
→ 전체 테스트 통과
→ 커밋
→ feature 브랜치 push
→ PR 생성 후 Claude Code 중단
→ Claude Code가 코드 리뷰 진행 후 PR에 코멘트 남기기
→ [APPROVE] Claude Code 중단 → 머지는 직접 진행
→ [REQUEST CHANGES] 재작업 후 RE-REVIEW 요청 코멘트
→ Claude Code 재리뷰 후 APPROVE → 머지는 직접 진행
→ develop 최신화 후 다음 작업