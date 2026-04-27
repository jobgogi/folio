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