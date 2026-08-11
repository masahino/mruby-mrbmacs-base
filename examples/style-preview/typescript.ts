interface User {
  readonly id: number;
  name: string;
}

async function greet(user: User): Promise<string> {
  const message = `Hello, ${user.name}`;
  return Promise.resolve(message);
}

const current: User = { id: 1, name: "mrbmacs" };
greet(current).then(console.log);
