# Contributing

By contributing, you agree that your contributions will be licensed under the MIT License.

Thank you for contributing to [PolyWindow-REBUILT](https://github.com/mmmmmmmmArbdghn/PolyWindow-REBUILT)! We LOVE your time and effort. Also, you may be subject to my "interesting" humor.

## Prerequisites

Before contributing, please ensure you have the following installed:

- **Polytoria Creator**: Version 2.x or higher
- **Polytoria Client**: Version 2.x or higher
- **Polytoria-compatible code editor**: Preferably VSCode (to match original environment), but you can choose your own with:
    - Git support
    - Polytoria 2.x (or Godot) compatibility
- **Git**: Latest version (usually bundled with VSCode)

Also, you must **know how git works**. Please don't accidentally leak your private email address. You can prevent this by going to your GitHub `Settings > Email`. In here, you can enable `Block command line pushes that expose my email` and `Keep my email addresses private`

### Installation Steps

1. Clone this repository:
```bash
git clone https://github.com/mmmmmmmmArbdghn/PolyWindow-REBUILT.git
cd PolyWindow-REBUILT
```

2. Open the cloned repository in **Polytoria Creator 2.x**

## Development Workflow

### Git Workflow

1. Fork the repository.
2. Clone your fork:
```bash
git clone https://github.com/YOUR-USERNAME/PolyWindow-REBUILT.git
cd PolyWindow-REBUILT
```
3. Create a feature branch:
```bash
git checkout -b feature-branch-name
```
4. Make your changes.
5. Commit:
```
bash
git commit -m "add feature"
```
6. Push your branch:
```bash
git push origin feature-branch-name
```
7. Open a pull request on GitHub against main.

### Pull Request Guidelines

When creating a pull request, please follow these steps:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-branch-name`
3. Make your changes (varies by which code editor you use)
4. Commit your changes: `git commit -m "add feature"`
5. Push the branch: `git push origin feature-branch-name`
6. Create a pull request

### Linting

I can only help you with linting in VSCode.

As explained in `README.md`, sometimes your VSCode installation might be cursed and you need to install `Luau LSP - Order` VSCode extension by Atomic Horizon **v1.67.2** alongside the `Luau Language Server` VSCode extension by Johnny Morganz (any version).

### Testing

Open `main.poly` **in Polytoria Creator 2.x or higher**, and hit `Play`, usually located at the top left.

## Code Style

We use the following formatting style guide/normal.

- Comments are non-capitalized except for variable names. Of course, you can style your own comments, but make sure that others can read them, preferably at a glance.
- Functions need explanations. Here is an example from `window:addEvent()`
```luau
-- registers a new bindable event.
-- @param id string: event id
-- @return table: self
function self:addEvent(id)
	if self.misc.eventObjects[id] then return self end
	self.misc.eventObjects[id] = Instance.New("BindableEvent")::BindableEvent
	return self
end
```
- Do not exceed 10 nest depth. Please. Use early-returns instead.
- Short early-returns are single-line to avoid cramping up the place, unless it's a behemoth of an if statement.

## Testing Guidelines

Before committing your changes, please ensure that:

- All linting rules pass
- All tests pass
- No new warnings appear
- Especially no new ERRORS appear

### Test Coverage Requirements

Code coverage definition: **How many lines are ran when testing** divided by **total lines executable**

- Source files should have at least 80% code coverage
- New source files should have at least 50% code coverage
- All test functions should be marked with `--@test` above it

## Pull Request Checklist

### For Feature Branches

- [ ] All linting rules pass
- [ ] All tests pass
- [ ] Code coverage is met (>=80%)

### For Bug Fixes

- [ ] All issues fixed are addressed
- [ ] No new warnings appear
- [ ] No new failures in tests
- [ ] No new bug appears
- [ ] Especially no more than 2 new bugs appear, which in this case I may ask: why?

### Pull Request Requirements

- [ ] Add a clear description of the issue being fixed
- [ ] Update the description with all changes
- [ ] Add a link to the issue in your description
- [ ] Ensure the title is clear and concise
- [ ] Include tests for all new features/changes

### Security

- [ ] Run your code at least once, please
- [ ] Check for edge cases in testing
- [ ] Ensure no sensitive data is exposed
- [ ] Include all necessary tests

### Memory Leaks

- [ ] Test your code for memory leaks
- [ ] For code with loops, run your code for over 5 minutes uninterrupted; increase in memory usage should be less than 10%
- [ ] Include all necessary tests

## Reporting Issues

If you encounter a bug or have a feature request, please create a new issue in the [issues](https://github.com/mmmmmmmmArbdghn/PolyWindow-REBUILT/issues) tab:

- **Title**: [Short description of the issue]
- **Description**: Clear description of the problem
- **Steps to Reproduce**: Step-by-step guide to reproduce the bug
- **Expected Behavior**: What should happen when you run the code
- **Actual Behavior**: What actually happens when you run the code
- **Code Snippets**: Relevant code snippets
- **Screenshots**: If applicable

## Questions?

Need help with something? Create a new issue on GitHub! I or other contributors would probably answer.