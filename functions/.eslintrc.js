module.exports = {
  env: {
    es6: true,
    node: true,
  },
  parserOptions: {
    ecmaVersion: 2018,
  },
  extends: ["eslint:recommended", "google"],
  rules: {
    "no-restricted-globals": ["error", "name", "length"],
    "prefer-arrow-callback": "error",
    quotes: "off",
    "max-len": "off", // Menonaktifkan aturan panjang maksimum
    "object-curly-spacing": "off", // Menonaktifkan aturan spasi dalam kurawal
    "no-unused-vars": "off",
    camelcase: "off",
    "quote-props": "off",
    "linebreak-style": 0,
    indent: "off",
    "comma-dangle": "off",
    "spaced-comment": "off",
    "require-jsdoc": [
      "error",
      {
        require: {
          FunctionDeclaration: true,
          MethodDefinition: false,
          ClassDeclaration: false,
        },
      },
    ], // Memeriksa persyaratan JSDoc
  },
  overrides: [
    {
      files: ["**/*.spec.*"],
      env: {
        mocha: true,
      },
      rules: {},
    },
  ],
  globals: {},
};
