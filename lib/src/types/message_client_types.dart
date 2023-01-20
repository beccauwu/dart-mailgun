import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:intl/intl.dart';

import 'client_types.dart';

/// Mailgun plan type
///
/// Used to determine which options are available for the plan.
///
/// Only scale and other plans are used as the others all have the same options.
///
/// For further information see the [Mailgun pricing](https://www.mailgun.com/pricing/).
enum MGPlanType { scale, other }

/// The possible values for the [o:tracking-clicks] option.
///
/// For further information see the [Mailgun documentation](https://documentation.mailgun.com/en/latest/api-sending.html#sending).
enum TrackingClicks { yes, no, htmlonly }

class MessageOptions {
  /// [planType] is used to determine which options are available for the plan.
  MGPlanType planType;
  bool? testMode;
  DateTime? deliveryTime;
  List<String>? tags;
  bool? dkim;
  String? _deliveryTimeOptimizePeriod;
  set deliveryTimeOptimizePeriod(int? value) {
    if (planType != MGPlanType.scale) {
      throw Exception(
          'o:deliverytime-optimize-period is only available for scale plans');
    }
    if (value == null) {
      _deliveryTimeOptimizePeriod = null;
      return;
    }
    if (value < 24 || value > 72) {
      throw FormatException(
          'deliveryTimeOptimizePeriod must be between 24 and 72 hours', value);
    }
    _deliveryTimeOptimizePeriod = '${value}H';
  }

  int? get deliveryTimeOptimizePeriod {
    if (_deliveryTimeOptimizePeriod == null) return null;
    return int.parse(_deliveryTimeOptimizePeriod!
        .substring(0, _deliveryTimeOptimizePeriod!.length - 1));
  }

  DateTime? _timeZoneLocalize;
  set timeZoneLocalize(String? value) {
    if (value == null) {
      _timeZoneLocalize = null;
      return;
    }
    if (planType != MGPlanType.scale) {
      throw Exception('o:time-zone-localize is only available for scale plans');
    }
    _timeZoneLocalize = DateFormat('j:m').parse(value);
  }

  String? get timeZoneLocalize => _timeZoneLocalize?.toString();
  bool? tracking;
  String? _trackingClicks;
  set trackingClicks(TrackingClicks? value) {
    if (value == null) {
      _trackingClicks = null;
      return;
    }
    _trackingClicks = value.toString().split('.').last;
  }

  TrackingClicks? get trackingClicks {
    if (_trackingClicks != null) {
      return TrackingClicks.values.firstWhere(
          (element) => element.toString().split('.').last == _trackingClicks);
    }
    return null;
  }

  bool? trackingOpens;
  bool? requireTLS;
  bool? skipVerification;
  Map<String, String>? _customHeaders;
  set customHeaders(Map<String, String>? value) {
    if (value == null) {
      _customHeaders = null;
      return;
    }
    _customHeaders = value.map((key, value) {
      key = key.toLowerCase().trim();
      key = key.startsWith('h:x-') ? key : 'h:X-$key';
      return MapEntry(key, value);
    });
  }

  Map<String, String>? get customHeaders => _customHeaders;
  Map<String, String>? _customVars;
  set customVars(Map<String, String>? value) {
    if (value == null) {
      _customVars = null;
      return;
    }
    _customVars = value.map((key, value) {
      key = key.toLowerCase().trim();
      key = key.startsWith('v:') ? key : 'v:$key';
      return MapEntry(key, value);
    });
  }

  Map<String, String>? get customVars => _customVars;
  Map<String, String>? recipientVars;
  MessageOptions(
      {int? deliveryTimeOptimizePeriod,
      String? timeZoneLocalize,
      TrackingClicks? trackingClicks,
      Map<String, String>? customHeaders,
      Map<String, String>? customVars,
      this.planType = MGPlanType.other,
      this.testMode,
      this.deliveryTime,
      this.tags,
      this.dkim,
      this.tracking,
      this.trackingOpens,
      this.requireTLS,
      this.skipVerification,
      this.recipientVars}) {
    this.deliveryTimeOptimizePeriod = deliveryTimeOptimizePeriod;
    this.timeZoneLocalize = timeZoneLocalize;
    this.trackingClicks = trackingClicks;
    this.customHeaders = customHeaders;
    this.customVars = customVars;
  }
  MultipartRequest toRequest(MultipartRequest request) {
    var fields = {...?_customHeaders, ...?_customVars, ..._asMap()};
    request.fields.addAll(fields);
    return request;
  }

  Map<String, String> _asMap() {
    return {
      if (testMode != null) 'o:testmode': testMode!.toString(),
      if (deliveryTime != null)
        'o:deliverytime': deliveryTime!.toIso8601String(),
      if (tags != null) 'o:tag': tags!.join(','),
      if (dkim != null) 'o:dkim': dkim!.toString(),
      if (tracking != null) 'o:tracking': tracking!.toString(),
      if (_trackingClicks != null) 'o:tracking-clicks': _trackingClicks!,
      if (trackingOpens != null) 'o:tracking-opens': trackingOpens!.toString(),
      if (requireTLS != null) 'o:require-tls': requireTLS!.toString(),
      if (skipVerification != null)
        'o:skip-verification': skipVerification!.toString(),
      if (planType == MGPlanType.scale && _deliveryTimeOptimizePeriod != null)
        'o:deliverytime-optimize-period': _deliveryTimeOptimizePeriod!,
      if (planType == MGPlanType.scale && _timeZoneLocalize != null)
        'o:time-zone-localize': _timeZoneLocalize!.toIso8601String(),
      if (recipientVars != null)
        'recipient-variables': json.encode(recipientVars),
    };
  }
}

enum MessageContentType { html, text, template }

/// The [MessageContent] class represents the content of an email.
///
/// The class provides factory constructors for creating instances of the class with different types of content.
/// The three types of content are [html], [text], and [template].
///
/// The class also provides a getter [templateVariables] which returns the [_templateVariables] field as a JSON string,
/// but it will throw an exception if the [type] is not [MessageContentType.template].
///
/// ## Examples:
/// using the [MessageContent.html] constructor:
///```dart
/// var htmlContent = MessageContent.html("test");
/// ```
/// using the [MessageContent.text] constructor:
/// ```dart
/// var textContent = MessageContent.text("test");
/// ```
/// using the [MessageContent.template] constructor:
/// ```dart
/// var templateContent = MessageContent.template("test", {"test": "test"});
/// ```
class MessageContent {
  /// Holds the actual content of the email.
  String value;

  /// Map that holds the variables that will be replaced in the template.
  ///
  /// _This field is only set when creating an instance of the class using the [MessageContent.template()] constructor._
  late Map<String, Object> _templateVariables;

  /// Holds the type of content to be sent.
  ///
  /// Possible values are [MessageContentType.html], [MessageContentType.text], and [MessageContentType.template].
  late MessageContentType _type;

  /// Initialises the class with [value] as html content, and sets [_type] to [MessageContentType.html].
  MessageContent.html(this.value) {
    this.value = value;
    this._type = MessageContentType.html;
  }

  /// Initialises the class with [value] as text content, and sets [_type] to [MessageContentType.text].
  MessageContent.text(this.value) {
    this.value = value;
    this._type = MessageContentType.text;
  }

  /// Initialises the class with [value] as the template name,
  /// and [_templateVariables] as a map of variables. Sets [_type] to [MessageContentType.template].
  MessageContent.template(this.value, Map<String, Object> templateVariables) {
    this._type = MessageContentType.template;
    this._templateVariables = templateVariables;
  }

  /// Returns the [_templateVariables] field as a JSON string.
  /// Throws [FormatException] if [type] is not [MessageContentType.template].
  ///
  /// _This shouldn't happen if the class is initialised correctly._
  String get templateVariables {
    if (type != MessageContentType.template) {
      throw FormatException('Not a template', type);
    }
    return json.encode(_templateVariables);
  }

  /// The [type] getter returns the type of content.
  MessageContentType get type => _type;

  /// Returns a map of the content.
  Map<String, String> asMap() {
    switch (_type) {
      case MessageContentType.html:
        return {'html': value};
      case MessageContentType.text:
        return {'text': value};
      case MessageContentType.template:
        return {'template': value, 'h:X-Mailgun-Variables': templateVariables};
    }
  }
}

abstract class MessageParamsBase {
  Future<MultipartRequest> toRequest(MultipartRequest request);
}

/// The [MessageParams] class is used to configure the request to the `messages` endpoint.
class MessageParams implements MessageParamsBase {
  /// The name and email address of the sender.
  ///
  /// format is `name <email>`
  String from;

  /// List of recipients.
  List<String> to;
  String subject;

  /// Instance of the [MessageContent] class.
  MessageContent content;
  List<String>? cc;
  List<String>? bcc;
  List<String>? tags;
  List<File>? attachments;
  List<String>? inline;
  MessageOptions? options;
  MessageParams(this.from, this.to, this.subject, this.content,
      {this.cc,
      this.bcc,
      this.tags,
      this.attachments,
      this.inline,
      this.options});
  Future<MultipartRequest> toRequest(MultipartRequest request) async {
    var fields = <String, String>{};
    fields['from'] = from;
    fields['to'] = to.join(',');
    fields['subject'] = subject;
    if (cc != null) fields['cc'] = cc!.join(',');
    if (bcc != null) fields['bcc'] = bcc!.join(',');
    if (tags != null) fields['o:tag'] = tags!.join(',');
    if (attachments != null) {
      for (var attachment in attachments!) {
        request.files.add(
          MultipartFile.fromBytes(
            'attachment',
            await attachment.readAsBytes(),
            filename: attachment.path.split('/').last,
          ),
        );
      }
    }
    if (inline != null) fields['inline'] = inline!.join(',');
    options?.toRequest(request);
    request.fields.addAll({...content.asMap(), ...fields});
    return request;
  }
}

class MimeMessageParams extends MessageParamsBase {
  List<String> to;
  File content;
  MimeMessageParams(this.to, this.content);
  Future<MultipartRequest> toRequest(MultipartRequest request) async {
    request.fields['to'] = to.join(',');
    request.files.add(
      await MultipartFile.fromPath('message', content.path),
    );
    return request;
  }
}

/// The [IMGMessageClient] interface defines methods for sending emails with the mailgun API.
///
/// Methods:
/// -------
/// - [IMGMessageClient.send] sends an email using the mailgun API.
///
/// Example:
/// -------
/// ```dart
/// class MyMailgunSender extends IMGMessageClient {
///  @override
///   Future<dynamic> send(
///     ...
///    ) async {
///     ...
///  }
/// }
/// ```
abstract class IMGMessageClient {
  /// Sends an email using the mailgun API.
  ///
  /// Takes [params] - an instance of [MessageParams]
  ///
  /// Returns [MGResponse] - an instance of the [MGResponse] class.
  Future<MGResponse> send(MessageParams params);

  /// Optional method for sending MIME messages.
  ///
  /// Takes [params] - an instance of [MimeMessageParams]
  Future<MGResponse>? sendMime(MimeMessageParams params);
}