# Git 전략

## 브랜치 구조
main
└── develop
    ├── feature/phase1-file-detector
    ├── feature/phase1-nas-client
    ├── feature/phase2-pdf-viewer
    └── ...

## 절대 금지
- git merge 직접 실행
- git push origin main
- git push origin develop
- PR 없이 main/develop 변경
- Approve 후 머지 직접 실행

## 브랜치 네이밍
feature/{phase}-{기능명}
예) feature/phase1-file-detector
    feature/phase2-pdf-viewer

## 작업 흐름
1. develop 최신화
   git checkout develop && git pull origin develop

2. feature 브랜치 생성
   git checkout -b feature/{name}

3. 작업 (TDD 사이클)

4. feature 브랜치 push
   git push origin feature/{name}

5. PR 생성 → Claude Code는 여기서 중단
   gh pr create \
     --base develop \
     --title "feat: {작업 내용}" \
     --body "## 작업 내용\n\n## 완료 조건\n- [ ] 테스트 통과\n- [ ] 리뷰 확인"

6. GitHub에서 PR 머지
7. develop 최신화
## 코드 리뷰 규칙

### PR 생성 후 리뷰 프로세스
1. PR 생성
2. Claude Code가 PR 전체 코드 리뷰 진행
3. 리뷰 코멘트 GitHub PR에 남기기
4. 이슈 없으면 Approve 후 머지
5. 이슈 있으면 Request Changes

### 리뷰 코멘트 형식
리뷰 코멘트는 아래 형식으로 작성

**[APPROVE]** 특이사항 없음. 머지 진행합니다.

**[REQUEST CHANGES]**
- 파일명: 지적 내용
  → 수정 방향 제안

예)
**[REQUEST CHANGES]**
- file_detector.dart: 파일 상단 주석 누락
  → .claude/rules/flutter.md 규칙에 맞게 주석 추가 필요
- file_detector.dart: _detectByExtension() 함수 주석 누락
  → @description, @param, @returns 추가 필요

### Request Changes 후 재작업 프로세스
1. 지적 사항 수정
2. 동일 feature 브랜치에 커밋
   fix(scope): 코드 리뷰 반영 - {수정 내용 요약}
3. push 후 PR에 재작업 완료 코멘트 남기기
4. Claude Code가 재리뷰 진행

### 재작업 완료 코멘트 형식
**[RE-REVIEW 요청]**
- 수정 항목: 수정 내용 요약
- 커밋: {커밋 해시}

예)
**[RE-REVIEW 요청]**
- file_detector.dart 파일 상단 주석 추가
- file_detector.dart _detectByExtension() 함수 주석 추가
- 커밋: a1b2c3d

### 재리뷰 후 Approve 코멘트 형식
**[APPROVE]**
- 지적 사항 전부 반영 확인
- 머지 진행합니다.