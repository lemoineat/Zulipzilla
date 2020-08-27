Zulipzilla is a simple [Bugzilla](https://www.bugzilla.org/) extension that posts messages to [Zulip](https://zulipchat.com/) whenever a bug is updated.


### Instructions

Clone this project into your bugzilla extensions directory. The `disabled` file will prevent the extension from being loaded (before you configure it)

Create a new Incoming webhook in Zulip and set in `Credentials.pm` its `BOT EMAIL` and its `API KEY`.

Copy of the file `Credentials.pm.template` into `Credentials.pm`, and modify the content of `Credentials.pm`:
- set the `BOT EMAIL` and the `API KEY` of the Zulip incoming webhook
- set also the URL of the Zulip server and the URL of the Bugzilla server.

Remove the `disabled` file


### Features

When a bug is updated, the bug change and its last comment is output into Zulip in the stream `Bugs` in the topic `Bug xxx` where xxx is the bug number.
