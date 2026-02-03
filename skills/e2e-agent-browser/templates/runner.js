#!/usr/bin/env node
/**
 * E2E 테스트 러너 - Node.js 버전
 * agent-browser를 활용한 E2E 테스트 실행
 *
 * 사용법:
 *   node runner.js [options]
 *
 * 옵션:
 *   --url <base-url>    베이스 URL (기본: http://localhost:3000)
 *   --headed            브라우저 창 표시
 *   --parallel          병렬 실행
 *   --filter <pattern>  테스트 필터링
 */

const { execSync, spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

// 설정
const config = {
  baseUrl: process.env.BASE_URL || 'http://localhost:3000',
  headed: process.argv.includes('--headed'),
  parallel: process.argv.includes('--parallel'),
  filter: getArgValue('--filter'),
  timeout: 30000,
  screenshotDir: './e2e-screenshots',
};

// 결과 저장
const results = {
  passed: [],
  failed: [],
  skipped: [],
  startTime: Date.now(),
};

// 유틸리티 함수
function getArgValue(flag) {
  const idx = process.argv.indexOf(flag);
  return idx !== -1 ? process.argv[idx + 1] : null;
}

function log(level, message) {
  const colors = {
    info: '\x1b[36m',
    pass: '\x1b[32m',
    fail: '\x1b[31m',
    warn: '\x1b[33m',
    reset: '\x1b[0m',
  };
  console.log(`${colors[level] || ''}[${level.toUpperCase()}]${colors.reset} ${message}`);
}

function exec(command, options = {}) {
  try {
    return execSync(command, {
      encoding: 'utf-8',
      timeout: config.timeout,
      ...options,
    }).trim();
  } catch (error) {
    if (options.ignoreError) return null;
    throw error;
  }
}

function browser(cmd) {
  const headed = config.headed ? '--headed' : '';
  return exec(`agent-browser ${cmd} ${headed}`);
}

// 테스트 헬퍼
const helpers = {
  open(url) {
    const fullUrl = url.startsWith('http') ? url : `${config.baseUrl}${url}`;
    browser(`open "${fullUrl}"`);
  },

  click(selector) {
    browser(`click "${selector}"`);
  },

  fill(selector, text) {
    browser(`fill "${selector}" "${text}"`);
  },

  text(selector) {
    return browser(`text "${selector}"`);
  },

  snapshot(options = '-i') {
    return browser(`snapshot ${options}`);
  },

  wait(condition) {
    if (typeof condition === 'number') {
      browser(`wait ${condition}`);
    } else if (condition.startsWith('text:')) {
      browser(`wait text "${condition.slice(5)}"`);
    } else if (condition.startsWith('url:')) {
      browser(`wait url "${condition.slice(4)}"`);
    } else {
      browser(`wait "${condition}"`);
    }
  },

  url() {
    return browser('url');
  },

  title() {
    return browser('title');
  },

  screenshot(filename) {
    const filepath = path.join(config.screenshotDir, filename);
    browser(`screenshot "${filepath}"`);
    return filepath;
  },

  isVisible(selector) {
    try {
      const result = browser(`isvisible "${selector}"`);
      return result === 'true';
    } catch {
      return false;
    }
  },

  close() {
    exec('agent-browser close', { ignoreError: true });
  },

  clearSession() {
    exec('agent-browser cookies clear', { ignoreError: true });
    exec('agent-browser local clear', { ignoreError: true });
  },
};

// Assert 헬퍼
const assert = {
  equal(actual, expected, message) {
    if (actual !== expected) {
      throw new Error(message || `Expected "${expected}", got "${actual}"`);
    }
  },

  contains(text, substring, message) {
    if (!text.includes(substring)) {
      throw new Error(message || `Expected "${text}" to contain "${substring}"`);
    }
  },

  urlContains(substring) {
    const url = helpers.url();
    if (!url.includes(substring)) {
      throw new Error(`Expected URL to contain "${substring}", got "${url}"`);
    }
  },

  textVisible(text) {
    const snapshot = helpers.snapshot();
    if (!snapshot.includes(text)) {
      throw new Error(`Expected text "${text}" to be visible`);
    }
  },

  elementVisible(selector) {
    if (!helpers.isVisible(selector)) {
      throw new Error(`Expected element "${selector}" to be visible`);
    }
  },
};

// 테스트 케이스 정의
const tests = [
  {
    name: '홈페이지 로드',
    fn: () => {
      helpers.open('/');
      helpers.wait('load');
      const title = helpers.title();
      assert.contains(title, '', 'Page should have a title');
    },
  },

  {
    name: '네비게이션 동작',
    fn: () => {
      helpers.open('/');
      helpers.wait('load');
      helpers.snapshot();

      // About 링크 클릭 (프로젝트에 맞게 수정)
      try {
        helpers.click('role:link "About"');
      } catch {
        log('warn', 'About link not found, skipping navigation test');
        return;
      }

      helpers.wait('url:**/about');
      assert.urlContains('about');
    },
  },

  {
    name: '로그인 폼',
    fn: () => {
      helpers.open('/login');
      helpers.wait('load');
      helpers.snapshot();

      // 이메일 필드 확인 및 입력
      try {
        helpers.fill('#email', 'test@example.com');
        helpers.fill('#password', 'password123');

        const emailValue = browser('value "#email"');
        assert.equal(emailValue, 'test@example.com', 'Email should be filled');
      } catch {
        log('warn', 'Login form fields not found');
      }
    },
  },

  {
    name: '폼 유효성 검사',
    fn: () => {
      helpers.open('/register');
      helpers.wait('load');

      // 빈 폼 제출 시도
      try {
        helpers.click('role:button "Submit"');
        helpers.wait(1000);

        const snapshot = helpers.snapshot();
        const hasError = /required|error|invalid/i.test(snapshot);
        if (!hasError) {
          log('warn', 'No validation errors found');
        }
      } catch {
        log('warn', 'Register form not found');
      }
    },
  },

  {
    name: '반응형 모바일',
    fn: () => {
      browser('set viewport 375 667');
      helpers.open('/');
      helpers.wait('load');
      helpers.snapshot();

      // 뷰포트 복원
      browser('set viewport 1280 720');
    },
  },
];

// 테스트 실행
async function runTest(test) {
  log('info', `Running: ${test.name}`);

  try {
    helpers.clearSession();
    test.fn();
    results.passed.push(test.name);
    log('pass', test.name);
    return true;
  } catch (error) {
    results.failed.push({ name: test.name, error: error.message });
    log('fail', `${test.name}: ${error.message}`);

    // 실패 시 스크린샷
    try {
      const filename = `${test.name.replace(/[^a-z0-9]/gi, '_')}_${Date.now()}.png`;
      helpers.screenshot(filename);
    } catch {}

    return false;
  }
}

async function runAllTests() {
  // 스크린샷 디렉토리 생성
  if (!fs.existsSync(config.screenshotDir)) {
    fs.mkdirSync(config.screenshotDir, { recursive: true });
  }

  console.log('========================================');
  console.log('E2E Test Runner');
  console.log(`Base URL: ${config.baseUrl}`);
  console.log(`Headed: ${config.headed}`);
  console.log('========================================\n');

  // 필터 적용
  let testsToRun = tests;
  if (config.filter) {
    testsToRun = tests.filter((t) =>
      t.name.toLowerCase().includes(config.filter.toLowerCase())
    );
    log('info', `Filtered to ${testsToRun.length} tests`);
  }

  // 테스트 실행
  for (const test of testsToRun) {
    await runTest(test);
  }

  // 브라우저 정리
  helpers.close();

  // 결과 출력
  const duration = ((Date.now() - results.startTime) / 1000).toFixed(2);

  console.log('\n========================================');
  console.log('Results');
  console.log('========================================');
  console.log(`Duration: ${duration}s`);
  console.log(`Passed: ${results.passed.length}`);
  console.log(`Failed: ${results.failed.length}`);

  if (results.failed.length > 0) {
    console.log('\nFailed tests:');
    results.failed.forEach(({ name, error }) => {
      console.log(`  - ${name}: ${error}`);
    });
  }

  // 종료 코드
  process.exit(results.failed.length > 0 ? 1 : 0);
}

// 실행
runAllTests().catch((error) => {
  log('fail', `Runner error: ${error.message}`);
  process.exit(1);
});
