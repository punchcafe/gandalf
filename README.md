# Gandalf  🧙 🔮  [![Tests](https://github.com/punchcafe/gandalf/actions/workflows/tests.yml/badge.svg)](https://github.com/punchcafe/gandalf/actions/workflows/tests.yml)

Gandalf is an open-source quiz application with a simple purpose: Help engineers discover what topics they should study next.



> 🚧 **Please Note!:** This app is still under development, but it needs a lot of help! If you are a software engineer who would like to help add some of your wisdom to this app, please look at the Contributing setion below.

The path of personal development for a Software Engineer can often feel daunting; hundreds of buzzword technologies, thounsands of arcane terms you've heard but don't really know about... Often times the hardest thing can just be deciding what to sit down and study next!

Gandalf aims to help developers by presenting them with a dynamic quiz based on their current role and known  technologies. It starts with broad questions from general topics related to the users choices, and then begins to narrow down into more specific questions for related sub topics. Once it's decided it's identified enough topics the user could do with some further study in, it presents these topics in a final report. It also provides a series of resources the user can use to further study those topics.

## Contributing 🔧

We're looking for anyone with professional experience who is willing to give some of their knowledge to make this app more useful to developing Engineers.

All of the resources displayed in the quiz app are in the `priv/resources` directory. There are three types:

- `questions`: These are question sets in `.yaml` files. Each question set has a `topic` and a series of questions. The topics follow a format of `<broad_topic>:<more_specific_topic>`.
- `profiles`: These represent career roles, e.g. `backend_engineer` or `devops_engineer`. In practicality, they are a lable and a list of `topic`s relevant to that label.
- `resources`: Resources (probably need a better name for this) are helpful resources for learning a given `topic`. They are what is shown to the user once the topics they need to work on have been determined. 

For contributions, please raise a PR with any changes or additions to these yaml files. If you are adding questions for topics you regularly blog about, you are very welcome to share your blog as a relevant resource for the topic.

## Road Map to `1.0.0` 🚀
There is still a fair ways to go before Gandalf is ready to be a permanently deployed app. This readme will also serve as a check list for what's left before `1.0.0`

- [ ] Add a proper landing page before starting quiz
- [ ] Update visual design with a proper layout + UX
- [ ] Enable PDF generation of final report
- [ ] Add a substantial amount of resources / questions / topics