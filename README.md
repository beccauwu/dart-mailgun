# flutter-mailgun

Send email through Mailgun API

Forked from [dotronglong](https://github.com/dotronglong/flutter-mailgun "forked repo link")'s repo as it had been unmaintaned for a while.

This is still heavily in development so do keep that in mind. I'll publish the package on pub as soon as I've properly tested it. If you want to add it to your project you'll therefore have to import it from github as shown below.

## Roadmap

- [ ] Make MGMessageClient work
- [ ] Create own types
- [ ] Add support for other Mailgun API endpoints
- [ ] Move tests to dart tests (remove flutter sdk as a dependency)


*Please discount everything below for now, I forgot to create the develop branch and made changes that aren't yet done, I'll try to make this work asap*
--------
## Getting Started

- Add dependency

```yaml
dependencies:
  flutter_mailgun:
    git: https://github.com/beccauwu/flutter-mailgun.git
```

- Initialize mailer instance

```dart
import 'package:flutter_mailgun/mailgun.dart';


var mailgun = MailgunSender(domain: "my-mailgun-domain", apiKey: "my-mailgun-api-key", regionIsEU: true);
```

- Send plain text email

```dart
var response = await mailgun.send(
  from: from,
  to: to,
  subject: "Test email",
  content: Content.text("your text"));
```

- Send HTML email

```dart
var response = await mailgun.send(
  from: from,
  to: to,
  subject: "Test email",
  content: Content.html("<strong>Hello World</strong>"));
```

- Send email using template and template's variables

```dart
var response = await mailgun.send({
  from: from,
  to: to,
  subject: "Test email",
  content: Content.template("my-template", {
      'author': 'John'
    });
  });
```

- Send email with attachments

```dart
var file = new File('photo.jpg');
var response = await mailgun.send(
  from: from,
  to: to,
  subject: "Test email",
  html: "Please check my <strong>attachment</strong>",
  attachments: [file]);
```

## Response

Below are possible statuses of `response.status`:

- `SendResponseStatus.OK`: mail is sent successfully
- `SendResponseStatus.QUEUED`: mail is added to queue, for example, mailgun is not delivered mail immediately
- `SendResponseStatus.FAIL`: failed to send email

In case of failure, error's message is under `response.message`


