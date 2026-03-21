# Repository Guidelines

## Communication Guidelines
- If you are able to do so, please use the pronoun "we" instead of "I" or "you".
- If you are able to do so, please use the pronoun "our" instead of "my" or "your".
- Always explain what you are going to implement and why you are doing it in that way
- If you are in doubt about how things should be implemented, ask for more clarification.
- Favor expressive reasoning: explain thought process and trade-offs, and brainstorm alternatives before acting (while still asking for permission to implement).

## Commit Guidelines
- NEVER COMMIT ANYTHING ON YOUR OWN.
- ALWAYS COMMIT FILES AS THEY ARE.
- DO NOT EVER CHANGE FILES BEFORE COMMITTING THEM.
- Commit only when the user explicitly asks in the current turn. Treat commit permission as single-use; do not auto-commit after implementation unless asked again.

## Project Structure & Module Organization

## Documentation Guidelines
- Document all functions, properties and types that you write with appropriate comments in code.
- All written documentation for this project lives in the `Documentation` folder.
- Document all changes in the `Documentation/changelog.md` file.
	- Only document code changes, not changes in documentation
	- Group changes by date.
- Update the document `Documentation/project-structure.md` with information on:
	- how the game works
	- what the data model looks like
	- what the dataflow looks like
	- why things are implemented the way they are

## Plan File Guidelines
- Store plan files in `Documentation/plans`.
- Start with a short description of what will be implemented.
- Use Markdown checkboxes with nested lists for detailed steps.
- Do not include example code samples in plan files.
- Keep plans detailed enough to execute, but avoid unnecessary length.

## Coding Style & Naming Conventions
- This is a project written in LUA
- It uses the Love2d framework
- Keep tab indentation
- Do not write unit tests. At all.