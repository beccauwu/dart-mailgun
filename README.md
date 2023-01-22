[![Dart](https://github.com/beccauwu/dart-mailgun/actions/workflows/dart.yml/badge.svg)](https://github.com/beccauwu/dart-mailgun/actions/workflows/dart.yml)

# dart-mailgun

Mailgun API client written in dart

Forked from [dotronglong](https://github.com/dotronglong/flutter-mailgun "forked repo link")'s repo as it had been unmaintaned for a while.

This is still heavily in development so do keep that in mind. I'll publish the package on pub as soon as I've properly tested it. If you want to add it to your project you'll therefore have to import it from github as shown below.

## Endpoint Support

### `/v3/<domain>`

|   | |
|---|---|
| `/messages`   | :white_check_mark:  |
| `/messages.mime`   |:white_check_mark:  |

### `/v4`

none of the v4 endpoints are currently supported but this is definitely something i will work on.

## Getting Started

- Add dependency

```yaml
dependencies:
  flutter_mailgun:
    git: https://github.com/beccauwu/flutter-mailgun.git
```

- Initialize client instance

```dart
import 'package:dart_mailgun/client.dart';


var client = MailgunClient(domain: "my-mailgun-domain", apiKey: "my-mailgun-api-key");
```

- Send plain text email

```dart
var messageClient = client.message
var params = MessageParams(
  from: from,
  to: to,
  subject: 'email',
  content: MessageContent.text('hello'),
)
```

- Send HTML email

```dart
var messageClient = client.message
var params = MessageParams(
  from: from,
  to: to,
  subject: 'email',
  content: MessageContent.html('<h1>hello</h1>'),
```

- Send email using template and template variables

```dart
var messageClient = client.message
var params = MessageParams(
  from: from,
  to: to,
  subject: 'email',
  content: MessageContent.template('mytemplate', {'var1': 'val1'}),
```

- Send email with attachments

```dart
var messageClient = client.message
var params = MessageParams(
  from: from,
  to: to,
  subject: 'email',
  content: MessageContent.text('hello'),
  attachments: [File('myfile.txt')],
```

## Response

Responses from any clients will be an instance of the Response class.

The response contains two methods: ok(), and status().
ok() returns a boolean indicating a successful response,
status() returns an instance of ResponseStatus, which contains the statuscode `status().code` and reasonphrase `status().reason`.

## Roadmap

- [ ] Add support for other endpoints:
  - [x] `/messages.mime`
  - [ ] `/events`
  - [ ] `/stats`
  - [ ] `/tags`
  - [ ] `/bounces`
  - [ ] `/routes`
  - [ ] `/domains/<domain>/webhooks`
  - [ ] `/lists`
  - [ ] `/templates`
- [x] Move tests to dart tests (remove flutter sdk as a dependency)
