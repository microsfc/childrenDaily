// commitlint.config.js
module.exports = {
    extends: ['@commitlint/config-conventional'],
    rules: {
      'type-enum': [
        2,
        'always',
        ['feat', 'fix', 'docs', 'style', 'refactor', 'test', 'chore'],
      ],
      'subject-case': [0], // disables subject capitalization rule
    },
  };
// This configuration extends the conventional commit rules and allows for a wider range of commit types.  