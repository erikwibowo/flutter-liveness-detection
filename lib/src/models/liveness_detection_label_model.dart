import 'dart:convert';

LivenessDetectionLabelModel livenessDetectionLabelModelFromJson(String str) => LivenessDetectionLabelModel.fromJson(json.decode(str));

String livenessDetectionLabelModelToJson(LivenessDetectionLabelModel data) => json.encode(data.toJson());

class LivenessDetectionLabelModel {
    String? smile;
    String? blink;

    LivenessDetectionLabelModel({
        this.smile,
        this.blink,
    });

    factory LivenessDetectionLabelModel.fromJson(Map<String, dynamic> json) => LivenessDetectionLabelModel(
        smile: json["smile"],
        blink: json["blink"],
    );

    Map<String, dynamic> toJson() => {
        "smile": smile,
        "blink": blink,
    };
}
