function clean(value, fallback) {
  const trimmed = typeof value === 'string' ? value.trim() : '';
  return trimmed || fallback;
}

function greet(name, options) {
  const nombre = clean(name, 'mundo');
  const saludo = clean(options && options.greeting, 'Hola');
  return `${saludo}, ${nombre}!`;
}

module.exports = { greet };
