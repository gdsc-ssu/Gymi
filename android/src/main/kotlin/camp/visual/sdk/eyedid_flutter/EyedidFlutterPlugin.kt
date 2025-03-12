package camp.visual.sdk.eyedid_flutter

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import androidx.core.content.ContextCompat
import camp.visual.eyedid.gazetracker.GazeTracker
import camp.visual.eyedid.gazetracker.callback.CalibrationCallback
import camp.visual.eyedid.gazetracker.callback.InitializationCallback
import camp.visual.eyedid.gazetracker.callback.StatusCallback
import camp.visual.eyedid.gazetracker.callback.TrackingCallback
import camp.visual.eyedid.gazetracker.constant.AccuracyCriteria
import camp.visual.eyedid.gazetracker.constant.CalibrationModeType
import camp.visual.eyedid.gazetracker.constant.CameraPreset
import camp.visual.eyedid.gazetracker.constant.GazeTrackerOptions
import camp.visual.eyedid.gazetracker.constant.InitializationErrorType
import camp.visual.eyedid.gazetracker.constant.StatusErrorType
import camp.visual.eyedid.gazetracker.device.CameraPosition
import camp.visual.eyedid.gazetracker.metrics.BlinkInfo
import camp.visual.eyedid.gazetracker.metrics.FaceInfo
import camp.visual.eyedid.gazetracker.metrics.GazeInfo
import camp.visual.eyedid.gazetracker.metrics.UserStatusInfo
import camp.visual.sdk.eyedid_flutter.constants.ArgumentKey
import camp.visual.sdk.eyedid_flutter.constants.ErrorMessage
import camp.visual.sdk.eyedid_flutter.constants.MethodName
import camp.visual.sdk.eyedid_flutter.constants.ResultKey
import camp.visual.sdk.eyedid_flutter.constants.event.CalibrationEvent
import camp.visual.sdk.eyedid_flutter.constants.event.DropEvent
import camp.visual.sdk.eyedid_flutter.constants.event.StatusEvent
import camp.visual.sdk.eyedid_flutter.constants.event.TrackingEvent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.Locale

/** EyedidFlutterPlugin */
class EyedidFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, InitializationCallback,
    StatusCallback, TrackingCallback, CalibrationCallback {
    private lateinit var channel: MethodChannel
    private var trackingEventSink: EventSink? = null
    private var dropEventSink: EventSink? = null
    private var statusEventSink: EventSink? = null
    private var calibrationEventSink: EventSink? = null

    private val eyedidError = "Eyedid SDK error"

    private val trackingEventConnected = Any()
    private val dropEventConnected = Any()

    private val statusEventConnected = Any()
    private val calibrationEventConnected = Any()
    private val methodConnected = Any()
    private var gazeTracker: GazeTracker? = null
    private var binding: ActivityPluginBinding? = null
    private var attempt: Boolean = false
    private var density: Float = 0.0f
    private var context: Context? = null
    private var initResult: Result? = null


    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel =
            MethodChannel(flutterPluginBinding.binaryMessenger, "eyedid.flutter.common.method")
        channel.setMethodCallHandler(this)
        initEventChannels(flutterPluginBinding.binaryMessenger)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            MethodName.INIT_GAZE_TRACKER -> {
                initGazeTracker(call, result)
            }

            MethodName.RELEASE_GAZE_TRACKER -> {
                if (checkCameraPermission()) {
                    releaseGazeTracker()
                    result.success(ResultKey.RELEASED)
                } else {
                    throwException(result, ErrorMessage.CAMERA_PERMISSION_ERROR_MESSAGE);
                }
            }

            MethodName.GET_VERSION_NAME -> {
                getVersionName(result)
            }

            MethodName.START_TRACKING -> {
                startTracking(result)
            }

            MethodName.STOP_TRACKING -> {
                stopTracking(result)
            }

            MethodName.IS_TRACKING -> {
                isTracking(result)
            }

            MethodName.HAS_CAMERA_POSITIONS -> {
                hasCameraPosition(result)
            }

            MethodName.ADD_CAMERA_POSITION -> {
                addCameraPosition(call, result)
            }

            MethodName.GET_CAMERA_POSITION -> {
                getCameraPosition(result)
            }

            MethodName.GET_CAMERA_POSITION_LIST -> {
                getCameraPositionList(result)
            }

            MethodName.SELECT_CAMERA_POSITION -> {
                selectCameraPosition(call, result)
            }

            MethodName.SET_TRACKING_FPS -> {
                setTrackingFPS(call, result)
            }

            MethodName.START_CALIBRATION -> {
                startCalibration(call, result)
            }

            MethodName.STOP_CALIBRATION -> {
                stopCalibration(result)
            }

            MethodName.IS_CALIBRATING -> {
                isCalibrating(result)
            }

            MethodName.START_COLLECT_SAMPLES -> {
                startCollectSamples(result)
            }

            MethodName.SET_CALIBRATION_DATA -> {
                setCalibrationData(call, result)
            }

            MethodName.SET_ATTENTION_REGION -> {
                setAttentionRegion(call, result)
            }

            MethodName.GET_ATTENTION_REGION -> {
                getAttentionRegion(result)
            }

            MethodName.REMOVE_ATTENTION_REGION -> {
                removeAttentionRegion(result)
            }

            MethodName.SET_FORCED_ORIENTATION, MethodName.RESET_FORCED_ORIENTATION -> {
                result.success("Android platform not supported.")
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun removeAttentionRegion(result: Result) {
        if (gazeTracker == null) {
            throwException(result, ErrorMessage.EYEDID_NOT_INITIALIZED_ERROR_MESSAGE)
        } else {
            gazeTracker?.removeAttentionRegion()
            result.success(null)
        }
    }

    private fun getAttentionRegion(result: Result) {
        if (gazeTracker == null) {
            throwException(result, ErrorMessage.EYEDID_NOT_INITIALIZED_ERROR_MESSAGE)
        } else {
            val region = gazeTracker!!.attentionRegion
            val regionMap = HashMap<String, Any>()
            regionMap[ArgumentKey.ATTENTION_REGION_LEFT] = region.left / density
            regionMap[ArgumentKey.ATTENTION_REGION_TOP] = region.top / density
            regionMap[ArgumentKey.ATTENTION_REGION_RIGHT] = region.right / density
            regionMap[ArgumentKey.ATTENTION_REGION_BOTTOM] = region.bottom / density
            result.success(regionMap)
        }
    }

    private fun setAttentionRegion(call: MethodCall, result: Result) {
        if (gazeTracker == null) {
            throwException(result, ErrorMessage.EYEDID_NOT_INITIALIZED_ERROR_MESSAGE)
        } else {
            val left = call.argument<Int>(ArgumentKey.ATTENTION_REGION_LEFT)
            val top = call.argument<Int>(ArgumentKey.ATTENTION_REGION_TOP)
            val right = call.argument<Int>(ArgumentKey.ATTENTION_REGION_RIGHT)
            val bottom = call.argument<Int>(ArgumentKey.ATTENTION_REGION_BOTTOM)

            if (left == null || top == null || right == null || bottom == null) {
                throwException(result, ErrorMessage.ARGUMENT_NULL_ERROR_MESSAGE)
            } else {
                gazeTracker?.setAttentionRegion(
                    left * density,
                    top * density,
                    right * density,
                    bottom * density
                )
                result.success(null)
            }
        }
    }

    private fun setCalibrationData(call: MethodCall, result: Result) {
        if (gazeTracker == null) {
            throwException(result, ErrorMessage.EYEDID_NOT_INITIALIZED_ERROR_MESSAGE)
        } else {
            val data = call.argument<List<Double>>(ArgumentKey.CALIBRATION_DATA)
            if (data == null) {
                throwException(result, ErrorMessage.ARGUMENT_NULL_ERROR_MESSAGE)
            } else {
                val value = gazeTracker?.setCalibrationData(data.toDoubleArray())
                result.success(value)
            }
        }
    }

    private fun startCollectSamples(result: Result) {
        if (gazeTracker == null) {
            throwException(result, ErrorMessage.EYEDID_NOT_INITIALIZED_ERROR_MESSAGE)
        } else {
            gazeTracker?.startCollectSamples()
            result.success(null)
        }
    }

    private fun isCalibrating(result: Result) {
        if (gazeTracker == null) {
            throwException(result, ErrorMessage.EYEDID_NOT_INITIALIZED_ERROR_MESSAGE)
        } else {
            result.success(gazeTracker!!.isCalibrating)
        }
    }

    private fun stopCalibration(result: Result) {
        if (gazeTracker == null) {
            throwException(result, ErrorMessage.EYEDID_NOT_INITIALIZED_ERROR_MESSAGE)
        } else {
            gazeTracker?.stopTracking()
            result.success(null)
        }
    }

    private fun startCalibration(call: MethodCall, result: Result) {
        if (gazeTracker == null) {
            throwException(result, ErrorMessage.EYEDID_NOT_INITIALIZED_ERROR_MESSAGE)
        } else {
            var calibrationMode = CalibrationModeType.FIVE_POINT
            var usePrevCalibration = false;

            val usePrevCalibrationResult = call.argument<Boolean>(ArgumentKey.USE_PREVIOUS_CALIBRATION)
            if (usePrevCalibrationResult != null) {
                usePrevCalibration = usePrevCalibrationResult
            }

            val modeInt = call.argument<Int>(ArgumentKey.CALIBRATION_MODE)
            if (modeInt != null && modeInt == 1) {
                calibrationMode = CalibrationModeType.ONE_POINT
            }
            var calibrationAccuracyCriteria = AccuracyCriteria.DEFAULT
            val accInt = call.argument<Int>(ArgumentKey.CALIBRATION_CRITERIA)
            if (accInt != null && accInt != 0) {
                calibrationAccuracyCriteria =
                    if (accInt < 0) AccuracyCriteria.LOW else AccuracyCriteria.HIGH
            }

            val left = call.argument<Float>(ArgumentKey.CALIBRATION_REGION_LEFT)
            val top = call.argument<Float>(ArgumentKey.CALIBRATION_REGION_TOP)
            val right = call.argument<Float>(ArgumentKey.CALIBRATION_REGION_RIGHT)
            val bottom = call.argument<Float>(ArgumentKey.CALIBRATION_REGION_BOTTOM)

            if (left != null && top != null && right != null && bottom != null) {
                gazeTracker?.startCalibration(
                    calibrationMode,
                    calibrationAccuracyCriteria,
                    left * density,
                    top * density,
                    right * density,
                    bottom * density,
                    usePrevCalibration
                )
            } else {
                gazeTracker?.startCalibration(calibrationMode, calibrationAccuracyCriteria, usePrevCalibration)
                result.success(null)
            }
        }
    }

    private fun setTrackingFPS(call: MethodCall, result: Result) {
        if (gazeTracker == null) {
            throwException(result, ErrorMessage.EYEDID_NOT_INITIALIZED_ERROR_MESSAGE)
        } else {
            val fps = call.argument<Int>(ArgumentKey.TRACKING_FPS)
            if (fps != null) {
                val value = gazeTracker!!.setTrackingFPS(fps)
                result.success(value)
            } else {
                throwException(result, ErrorMessage.ARGUMENT_NULL_ERROR_MESSAGE)
            }
        }
    }

    private fun selectCameraPosition(call: MethodCall, result: Result) {
        if (gazeTracker == null) {
            throwException(result, ErrorMessage.EYEDID_NOT_INITIALIZED_ERROR_MESSAGE)
        } else {
            val idx = call.argument<Int>(ArgumentKey.CAMERA_POSITION_INDEX)
            if (idx != null) {
                gazeTracker?.selectCameraPosition(idx)
                result.success(null)
            }
        }
    }

    private fun getCameraPositionList(result: Result) {
        if (gazeTracker == null) {
            throwException(result, ErrorMessage.EYEDID_NOT_INITIALIZED_ERROR_MESSAGE)
        } else {
            val list = gazeTracker?.cameraPositionList
            var mapList = ArrayList<HashMap<String, Any>>()
            if (list != null) {
                for (cp in list) {
                    val cameraPosition = generateMapWithCameraPosition(cp)
                    mapList.add(cameraPosition)
                }
            }
            result.success(mapList)
        }
    }

    private fun getCameraPosition(result: Result) {
        if (gazeTracker == null) {
            throwException(result, ErrorMessage.EYEDID_NOT_INITIALIZED_ERROR_MESSAGE)
        } else {
            val cp = gazeTracker?.cameraPosition
            if (cp == null) {
                result.success("Camera Position Null")
            } else {
                val map = generateMapWithCameraPosition(cp)
                result.success(map)
            }
        }
    }

    private fun addCameraPosition(call: MethodCall, result: Result) {
        if (gazeTracker == null) {
            throwException(result, ErrorMessage.EYEDID_NOT_INITIALIZED_ERROR_MESSAGE)
        } else {
            val cp = generateCameraPosition(call)
            if (cp == null) {
                throwException(result, ErrorMessage.ARGUMENT_NULL_ERROR_MESSAGE)
            } else {
                gazeTracker?.addCameraPosition(cp)
                result.success(null)
            }
        }
    }

    private fun generateMapWithCameraPosition(cp: CameraPosition): HashMap<String, Any> {
        val map = HashMap<String, Any>()
        map[ArgumentKey.MODEL_NAME] = cp.modelName
        map[ArgumentKey.SCREEN_WIDTH] = cp.screenWidth
        map[ArgumentKey.SCREEN_HEIGHT] = cp.screenHeight
        map[ArgumentKey.SCREEN_ORIGIN_X] = cp.screenOriginX
        map[ArgumentKey.SCREEN_ORIGIN_Y] = cp.screenOriginY
        map[ArgumentKey.CAMERA_ON_LONGER_AXIS] = cp.cameraOnLongerAxis
        return map
    }

    private fun generateCameraPosition(call: MethodCall): CameraPosition? {
        val modelName = call.argument<String>(ArgumentKey.MODEL_NAME) ?: return null
        val screenWidth = call.argument<Double>(ArgumentKey.SCREEN_WIDTH)?.toFloat() ?: return null
        val screenHeight =
            call.argument<Double>(ArgumentKey.SCREEN_HEIGHT)?.toFloat() ?: return null
        val screenOriginX =
            call.argument<Double>(ArgumentKey.SCREEN_ORIGIN_X)?.toFloat() ?: return null
        val screenOriginY =
            call.argument<Double>(ArgumentKey.SCREEN_ORIGIN_Y)?.toFloat() ?: return null
        val cameraOnLongerAxis = call.argument<Boolean>(ArgumentKey.CAMERA_ON_LONGER_AXIS) ?: false

        return CameraPosition(
            modelName,
            screenWidth,
            screenHeight,
            screenOriginX,
            screenOriginY,
            cameraOnLongerAxis
        )
    }

    private fun hasCameraPosition(result: Result) {
        if (gazeTracker == null) {
            throwException(result, ErrorMessage.EYEDID_NOT_INITIALIZED_ERROR_MESSAGE)
        } else {
            val hasCp = gazeTracker!!.hasCameraPositions()
            result.success(hasCp)
        }
    }

    private fun isTracking(result: Result) {
        if (gazeTracker == null) {
            throwException(result, ErrorMessage.EYEDID_NOT_INITIALIZED_ERROR_MESSAGE)
        } else {
            val isTracking = gazeTracker!!.isTracking
            result.success(isTracking)
        }
    }

    private fun stopTracking(result: Result) {
        if (checkCameraPermission()) {
            if (gazeTracker == null) {
                throwException(result, ErrorMessage.EYEDID_NOT_INITIALIZED_ERROR_MESSAGE)
            } else {
                gazeTracker?.stopTracking()
                result.success(null)
            }
        } else {
            throwException(result, ErrorMessage.CAMERA_PERMISSION_ERROR_MESSAGE)
        }
    }

    private fun startTracking(result: Result) {
        if (checkCameraPermission()) {
            if (gazeTracker == null) {
                throwException(result, ErrorMessage.EYEDID_NOT_INITIALIZED_ERROR_MESSAGE)
            } else {
                gazeTracker?.startTracking()
                result.success(null)
            }
        } else {
            throwException(result, ErrorMessage.CAMERA_PERMISSION_ERROR_MESSAGE)
        }
    }

    private fun releaseGazeTracker() {
        synchronized(methodConnected) {
            gazeTracker?.stopTracking()
            synchronized(trackingEventConnected) {
                trackingEventSink?.endOfStream()
                trackingEventSink = null
            }
            synchronized(statusEventConnected) {
                statusEventSink?.endOfStream()
                statusEventSink = null
            }
            synchronized(calibrationEventConnected) {
                calibrationEventSink?.endOfStream()
                calibrationEventSink = null
            }
            GazeTracker.releaseGazeTracker(gazeTracker)
            gazeTracker = null
        }
    }

    private fun checkCameraPermission(): Boolean {
        if (binding == null) return false
        val activity = binding!!.activity
        return ContextCompat.checkSelfPermission(
            activity,
            Manifest.permission.CAMERA
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun initGazeTracker(call: MethodCall, result: Result) {
        synchronized(methodConnected) {
            if (checkCameraPermission()) {
                if (gazeTracker == null) {
                    if (attempt) {
                        val resultMap = HashMap<String, Any>()
                        resultMap[ResultKey.INITIALIZED_RESULT_KEY] = false
                        resultMap[ResultKey.INITIALIZED_RESULT_MESSAGE_KEY] = ErrorMessage.IS_ALREADY_ATTEMPTING
                        result.success(resultMap)
                    } else {
                        attempt = true
                        val license = generateLicenseKey(call)
                        if (license == null) {
                            attempt = false
                            throwException(result, ErrorMessage.ARGUMENT_NULL_ERROR_MESSAGE)
                        } else {
                            val callback: InitializationCallback = this
                            val options = generateGazeTrackerOptions(call)
                            if (binding != null && context != null) {
                                binding?.activity?.runOnUiThread {
                                    initResult = result
                                    GazeTracker.initGazeTracker(
                                        context!!,
                                        license,
                                        callback,
                                        options
                                    )
                                }
                            } else {
                                attempt = false;
                                throwException(result, ErrorMessage.CONTEXT_NULL)
                            }
                        }
                    }
                } else {
                    val resultMap = HashMap<String, Any>()
                    resultMap[ResultKey.INITIALIZED_RESULT_KEY] = false
                    resultMap[ResultKey.INITIALIZED_RESULT_MESSAGE_KEY] = ErrorMessage.GAZE_TRACKER_ALREADY_INITIALIZED
                    result.success(resultMap)
                }
            } else {
                throwException(result, ErrorMessage.CAMERA_PERMISSION_ERROR_MESSAGE)
            }
        }
    }

    private fun generateGazeTrackerOptions(call: MethodCall): GazeTrackerOptions? {
        val useBlink = call.argument<Boolean>(ArgumentKey.USE_BLINK)
        val useUserStatus = call.argument<Boolean>(ArgumentKey.USE_USER_STATUS)
        val useGazeFilter = call.argument<Boolean>(ArgumentKey.USE_GAZE_FILTER)
        val maxConcurrency = call.argument<Int>(ArgumentKey.MAX_CONCURRENCY)
        val cameraPreset = call.argument<String>(ArgumentKey.CAMERA_PRESET)
        if (useBlink != null || useUserStatus != null || useGazeFilter != null || maxConcurrency != null || cameraPreset != null) {
            val builder = GazeTrackerOptions.Builder()
            useBlink?.let { builder.setUseBlink(it) }
            useUserStatus?.let { builder.setUseUserStatus(it) }
            useGazeFilter?.let { builder.setUseGazeFilter(it) }
            maxConcurrency?.let { builder.setMaxConcurrency(it) }
            cameraPreset?.let { preset ->
                builder.setCameraPreset(CameraPreset.valueOf(preset.uppercase(Locale.ROOT)))
                return builder.build()
            }
        }
        return null
    }

    private fun generateLicenseKey(call: MethodCall): String? {
        return call.argument<String>(ArgumentKey.LICENSE)
    }

    private fun throwException(result: Result, message: String) {
        result.error(eyedidError, message, null)
    }

    private fun getVersionName(result: Result) {
        val versionMap = HashMap<String, String>()
        versionMap[ResultKey.EYEDID_VERSION] = GazeTracker.getVersionName()
        result.success(versionMap)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        trackingEventSink = null
        statusEventSink = null
        calibrationEventSink = null
    }

    private fun initEventChannels(messenger: BinaryMessenger) {
        val trackingEventChannel = EventChannel(messenger, "eyedid.flutter.event.tracking")
        val dropEventChannel = EventChannel(messenger, "eyedid.flutter.event.drop")
        val statusEventChannel = EventChannel(messenger, "eyedid.flutter.event.status")
        val calibrationEventChannel = EventChannel(messenger, "eyedid.flutter.event.calibration")

        trackingEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                synchronized(trackingEventConnected) {
                    if (events != null) {
                        trackingEventSink = events
                    }
                }
            }

            override fun onCancel(arguments: Any?) {
                synchronized(trackingEventConnected) {
                    trackingEventSink = null
                }
            }
        })

        dropEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventSink?) {
                synchronized(dropEventConnected) {
                    if (events != null) {
                        dropEventSink = events
                    }
                }
            }

            override fun onCancel(arguemnts: Any?) {
                synchronized(dropEventConnected) {
                    dropEventSink = null
                }
            }
        })
        statusEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                synchronized(statusEventConnected) {
                    if (events != null) {
                        statusEventSink = events
                    }
                }
            }

            override fun onCancel(arguments: Any?) {
                synchronized(statusEventConnected) {
                    statusEventSink = null
                }
            }
        })

        calibrationEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                synchronized(calibrationEventConnected) {
                    if (events != null) {
                        calibrationEventSink = events
                    }
                }
            }

            override fun onCancel(arguments: Any?) {
                synchronized(calibrationEventConnected) {
                    calibrationEventSink = null
                }
            }
        })
    }

    override fun onInitialized(tracker: GazeTracker?, error: InitializationErrorType?) {
        var isSuccess = false
        val resultMap = HashMap<String, Any>()
        if (error == InitializationErrorType.ERROR_NONE) {
            this.gazeTracker = tracker
            this.gazeTracker?.setTrackingCallback(this)
            this.gazeTracker?.setCalibrationCallback(this)
            this.gazeTracker?.setStatusCallback(this)
            isSuccess = true
        }
        resultMap[ResultKey.INITIALIZED_RESULT_KEY] = isSuccess
        resultMap[ResultKey.INITIALIZED_RESULT_MESSAGE_KEY] = error.toString()
        initResult?.success(resultMap)
        initResult = null
        attempt = false
    }

    override fun onStarted() {
        synchronized(statusEventConnected) {
            val eventData = HashMap<String, Any>()
            eventData[StatusEvent.STATUS_EVENT_TYPE_KEY] = StatusEvent.STATUS_EVENT_START_TYPE
            this.binding?.activity?.runOnUiThread {
                statusEventSink?.success(eventData)
            }
        }
    }

    override fun onStopped(error: StatusErrorType) {
        synchronized(statusEventConnected) {
            val eventData = HashMap<String, Any>()
            eventData[StatusEvent.STATUS_EVENT_TYPE_KEY] = StatusEvent.STATUS_EVENT_STOP_TYPE
            eventData[StatusEvent.STATUS_EVENT_FAILED_REASON_KEY] = error.toString()
            this.binding?.activity?.runOnUiThread {
                statusEventSink?.success(eventData)
            }
        }
    }

    override fun onMetrics(
        timestamp: Long,
        gazeInfo: GazeInfo,
        faceInfo: FaceInfo,
        blinkInfo: BlinkInfo,
        userStatusInfo: UserStatusInfo
    ) {
        val trackingEvent =
            generateTrackingEvent(timestamp, gazeInfo, faceInfo, blinkInfo, userStatusInfo)
        this.binding?.activity?.runOnUiThread {
            trackingEventSink?.success(trackingEvent)
        }
    }

    override fun onDrop(timestamp: Long) {
        val dropEvent = generateDropEvent(timestamp)
        this.binding?.activity?.runOnUiThread {
            dropEventSink?.success(dropEvent)
        }
    }

    private fun generateTrackingEvent(
        timestamp: Long,
        gazeInfo: GazeInfo,
        faceInfo: FaceInfo,
        blinkInfo: BlinkInfo,
        userStatusInfo: UserStatusInfo
    ): Map<String, Any> {
        val map = HashMap<String, Any>()
        map[TrackingEvent.Key.TIMESTAMP] = timestamp

        map[TrackingEvent.Key.GAZE_X] = gazeInfo.x / density
        map[TrackingEvent.Key.GAZE_Y] = gazeInfo.y / density
        map[TrackingEvent.Key.FIXATION_X] = gazeInfo.fixationX / density
        map[TrackingEvent.Key.FIXATION_Y] = gazeInfo.fixationY / density
        map[TrackingEvent.Key.TRACKING_STATE] = gazeInfo.trackingState.toString()
        map[TrackingEvent.Key.EYE_MOVEMENT_STATE] = gazeInfo.eyeMovementState.toString()
        map[TrackingEvent.Key.SCREEN_STATE] = gazeInfo.screenState.toString()

        map[TrackingEvent.Key.FACE_SCORE] = faceInfo.score
        map[TrackingEvent.Key.FRAME_WIDTH] = faceInfo.frameSize.width
        map[TrackingEvent.Key.FRAME_HEIGHT] = faceInfo.frameSize.height
        map[TrackingEvent.Key.FACE_LEFT] = faceInfo.left
        map[TrackingEvent.Key.FACE_TOP] = faceInfo.top
        map[TrackingEvent.Key.FACE_RIGHT] = faceInfo.right
        map[TrackingEvent.Key.FACE_BOTTOM] = faceInfo.bottom
        map[TrackingEvent.Key.FACE_PITCH] = faceInfo.pitch
        map[TrackingEvent.Key.FACE_YAW] = faceInfo.yaw
        map[TrackingEvent.Key.FACE_ROLL] = faceInfo.roll
        map[TrackingEvent.Key.FACE_CENTER_X] = faceInfo.centerX
        map[TrackingEvent.Key.FACE_CENTER_Y] = faceInfo.centerY
        map[TrackingEvent.Key.FACE_CENTER_Z] = faceInfo.centerZ

        map[TrackingEvent.Key.IS_BLINK] = blinkInfo.isBlink
        map[TrackingEvent.Key.IS_BLINK_LEFT] = blinkInfo.isBlinkLeft
        map[TrackingEvent.Key.IS_BLINK_RIGHT] = blinkInfo.isBlinkRight
        map[TrackingEvent.Key.LEFT_OPENNESS] = blinkInfo.leftOpenness
        map[TrackingEvent.Key.RIGHT_OPENNESS] = blinkInfo.rightOpenness

        map[TrackingEvent.Key.IS_DROWSY] = userStatusInfo.isDrowsy
        map[TrackingEvent.Key.DROWSINESS_INTENSITY] = userStatusInfo.drowsinessIntensity
        map[TrackingEvent.Key.ATTENTION_SCORE] = userStatusInfo.attentionScore

        return map
    }

    private fun generateDropEvent(timestamp: Long): Map<String, Any> {
        val map = HashMap<String, Any>()
        map[DropEvent.Key.TIMESTAMP] = timestamp
        return map
    }

    override fun onCalibrationProgress(progress: Float) {
        synchronized(calibrationEventConnected) {
            val eventMap = HashMap<String, Any>()
            eventMap[CalibrationEvent.Key.CALIBRATION_TYPE] =
                CalibrationEvent.Type.CALIBRATION_PROGRESS
            eventMap[CalibrationEvent.Key.PROGRESS] = progress

            binding?.activity?.runOnUiThread {
                calibrationEventSink?.success(eventMap)
            }
        }
    }

    override fun onCalibrationNextPoint(x: Float, y: Float) {
        synchronized(calibrationEventConnected) {
            val eventMap = HashMap<String, Any>()
            eventMap[CalibrationEvent.Key.CALIBRATION_TYPE] =
                CalibrationEvent.Type.CALIBRATION_NEXT_XY
            eventMap[CalibrationEvent.Key.NEXT_X] = x / density
            eventMap[CalibrationEvent.Key.NEXT_Y] = y / density

            binding?.activity?.runOnUiThread {
                calibrationEventSink?.success(eventMap)
            }
        }
    }

    override fun onCalibrationFinished(calibrationData: DoubleArray) {
        synchronized(calibrationEventConnected) {
            val eventMap = HashMap<String, Any>()
            eventMap[CalibrationEvent.Key.CALIBRATION_TYPE] =
                CalibrationEvent.Type.CALIBRATION_FINISHED
            eventMap[CalibrationEvent.Key.CALIBRATION_DATA] = calibrationData

            binding?.activity?.runOnUiThread {
                calibrationEventSink?.success(eventMap)
            }
        }
    }

    override fun onCalibrationCanceled(calibrationData: DoubleArray) {
        synchronized(calibrationEventConnected) {
            val eventMap = HashMap<String, Any>()
            eventMap[CalibrationEvent.Key.CALIBRATION_TYPE] = CalibrationEvent.Type.CALIBRATION_CANCELED
            eventMap[CalibrationEvent.Key.CALIBRATION_DATA] = calibrationData
            binding?.activity?.runOnUiThread {
                calibrationEventSink?.success(eventMap)
            }
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.binding = binding
        if (this.binding != null) {
            density = this.binding!!.activity.resources.displayMetrics.density
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        this.binding = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        if (this.binding != binding) {
            this.binding = binding
        }
    }

    override fun onDetachedFromActivity() {
        this.binding = null;
    }
}
