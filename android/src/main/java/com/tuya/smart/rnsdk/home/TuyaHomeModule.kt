package com.tuya.smart.rnsdk.home

import com.facebook.react.bridge.*
import com.tuya.smart.android.common.utils.L
import com.tuya.smart.home.sdk.TuyaHomeSdk
import com.tuya.smart.home.sdk.api.ITuyaHome
import com.tuya.smart.home.sdk.api.ITuyaHomeStatusListener
import com.tuya.smart.home.sdk.bean.HomeBean
import com.tuya.smart.home.sdk.bean.RoomBean
import com.tuya.smart.home.sdk.callback.ITuyaGetRoomListCallback
import com.tuya.smart.home.sdk.callback.ITuyaHomeResultCallback
import com.tuya.smart.home.sdk.callback.ITuyaResultCallback
import com.tuya.smart.home.sdk.callback.ITuyaRoomResultCallback
import com.tuya.smart.rnsdk.utils.*
import com.tuya.smart.rnsdk.utils.Constant.DEVIDLIST
import com.tuya.smart.rnsdk.utils.Constant.GEONAME
import com.tuya.smart.rnsdk.utils.Constant.HOMEID
import com.tuya.smart.rnsdk.utils.Constant.IDLIST
import com.tuya.smart.rnsdk.utils.Constant.LAT
import com.tuya.smart.rnsdk.utils.Constant.LON
import com.tuya.smart.rnsdk.utils.Constant.NAME
import com.tuya.smart.rnsdk.utils.Constant.PRODUCTID
import com.tuya.smart.rnsdk.utils.Constant.ROOMID
import com.tuya.smart.rnsdk.utils.Constant.getIResultCallback
import com.tuya.smart.sdk.bean.GroupDeviceBean


class TuyaHomeModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {
    override fun getName(): String {
        return "TuyaHomeModule"
    }

    /* 初始化家庭下的所有数据 - 홈 정보 준비 via Network */
    // Checked by Using
    @ReactMethod
    fun getHomeDetail(params: ReadableMap, promise: Promise) {
        if (ReactParamsCheck.checkParams(arrayOf(HOMEID), params)) {
            getHomeInstance(params.getDouble(HOMEID))?.getHomeDetail(getITuyaHomeResultCallback(promise))
        }
    }

    /* 获取本地缓存中的数据信息 - 홈 정보 준비 via 캐시 */
    @ReactMethod
    fun getHomeLocalCache(params: ReadableMap, promise: Promise) {
        if (ReactParamsCheck.checkParams(arrayOf(HOMEID), params)) {
            getHomeInstance(params.getDouble(HOMEID))?.getHomeLocalCache(getITuyaHomeResultCallback(promise))
        }
    }

    /* 更新家庭信息 - 홈 정보 업데이트 */
    @ReactMethod
    fun updateHome(params: ReadableMap, promise: Promise) {
        if (ReactParamsCheck.checkParams(arrayOf(HOMEID, NAME, LON, LAT, GEONAME), params)) {
            getHomeInstance(params.getDouble(HOMEID))?.updateHome(params.getString(NAME), params.getDouble(LON), params.getDouble(LAT), params.getString(GEONAME), getIResultCallback(promise))
        }
    }

    /* 解散家庭 - 홈 정보 삭제 */
    @ReactMethod
    fun dismissHome(params: ReadableMap, promise: Promise) {
        if (ReactParamsCheck.checkParams(arrayOf(HOMEID), params)) {
            getHomeInstance(params.getDouble(HOMEID))?.dismissHome(getIResultCallback(promise))
        }
    }

    /* 添加房间 - 방 추가 */
    @ReactMethod
    fun addRoom(params: ReadableMap, promise: Promise) {
        if (ReactParamsCheck.checkParams(arrayOf(HOMEID, NAME), params)) {
            getHomeInstance(params.getDouble(HOMEID))?.addRoom(params.getString(NAME), getITuyaRoomResultCallback(promise))
        }
    }

    /* 移除房间 - 방 삭제 */
    @ReactMethod
    fun removeRoom(params: ReadableMap, promise: Promise) {
        if (ReactParamsCheck.checkParams(arrayOf(HOMEID, ROOMID), params)) {
            getHomeInstance(params.getDouble(HOMEID))?.removeRoom(params.getDouble(ROOMID).toLong(), getIResultCallback(promise))
        }
    }

    @ReactMethod
    fun sortRoom(params: ReadableMap, promise: Promise) {
        if (ReactParamsCheck.checkParams(arrayOf(HOMEID, IDLIST), params)) {
            var list = ArrayList<Long>()
            var length = (params.getArray(IDLIST) as ReadableArray).size()
            for (index in 0..length - 1) {
                list.add((params.getArray(IDLIST) as ReadableArray).getDouble(index).toLong())
            }
            getHomeInstance(params.getDouble(HOMEID))?.sortRoom(list, getIResultCallback(promise))
        }
    }

    /* 排序房间 - 홈 정렬 */
    @ReactMethod
    fun sortHome(params: ReadableMap, promise: Promise) {
        if (ReactParamsCheck.checkParams(arrayOf(HOMEID, IDLIST), params)) {
            var list = ArrayList<Long>()
            var length = (params.getArray(IDLIST) as ReadableArray).size()
            for (index in 0..length - 1) {
                list.add((params.getArray(IDLIST) as ReadableArray).getDouble(index).toLong())
            }
            getHomeInstance(params.getDouble(HOMEID))?.sortHome(list, getIResultCallback(promise))
        }
    }


    /* 查询房间列表 - 방 목록 요청 */
    @ReactMethod
    fun queryRoomList(params: ReadableMap, promise: Promise) {
        if (ReactParamsCheck.checkParams(arrayOf(HOMEID), params)) {
            getHomeInstance(params.getDouble(HOMEID))?.queryRoomList(ITuyaGetRoomListCallback(promise))
        }
    }

    /* 创建群组 - 그룹 생성 */
    @ReactMethod
    fun createGroup(params: ReadableMap, promise: Promise) {
        if (ReactParamsCheck.checkParams(arrayOf(HOMEID, PRODUCTID, NAME, DEVIDLIST), params)) {
            var list = ArrayList<String>()
            var length = (params.getArray(DEVIDLIST) as ReadableArray).size()
            for (index in 0..length) {
                list.add((params.getArray(DEVIDLIST) as ReadableArray).getString(index) as String)
            }
            getHomeInstance(params.getDouble(HOMEID))?.createGroup(
                    params.getString(PRODUCTID),
                    params.getString(NAME),
                    list,
                    object : ITuyaResultCallback<Long> {
                        override fun onSuccess(var1: Long) {
                            promise.resolve(var1)
                        }

                        override fun onError(var1: String, var2: String) {
                            promise.reject(var1, var2)
                        }
                    }
            )
        }
    }


    /* 监听家庭下面信息(设备的新增或者删除)变更的监听 - 홈에 속한 기기 정보 변경(장비 추가/삭제) 모니터링 */
    @ReactMethod
    fun registerHomeStatusListener(params: ReadableMap) {
        if (ReactParamsCheck.checkParams(arrayOf(HOMEID), params)) {
            getHomeInstance(params.getDouble(HOMEID))?.registerHomeStatusListener(object : ITuyaHomeStatusListener{
                override fun onDeviceAdded(var1: String){
                    val map = Arguments.createMap()
                    map.putString("devId", var1)
                    map.putDouble("homeId", params.getDouble(HOMEID))
                    map.putString("type","onDeviceAdded");
                    BridgeUtils.homeStatus(reactApplicationContext,map,params.getString(HOMEID) as String)
                }

                override fun onDeviceRemoved(var1: String){
                    val map = Arguments.createMap()
                    map.putString("devId", var1)
                    map.putDouble("homeId", params.getDouble(HOMEID))
                    map.putString("type","onDeviceRemoved");
                    BridgeUtils.homeStatus(reactApplicationContext,map,params.getString(HOMEID) as String)
                }

                override fun onGroupAdded(var1: Long){
                    val map = Arguments.createMap()
                    map.putDouble("groupId", var1.toDouble())
                    map.putDouble("homeId", params.getDouble(HOMEID))
                    map.putString("type","onGroupAdded");
                    BridgeUtils.homeStatus(reactApplicationContext,map,params.getString(HOMEID) as String)
                }

                override fun onGroupRemoved(var1: Long){
                    val map = Arguments.createMap()
                    map.putDouble("groupId", var1.toDouble())
                    map.putDouble("homeId", params.getDouble(HOMEID))
                    map.putString("type","onGroupRemoved");
                    BridgeUtils.homeStatus(reactApplicationContext,map,params.getString(HOMEID) as String)
                }

                override fun onMeshAdded(var1: String){
                    val map = Arguments.createMap()
                    map.putDouble("meshId", var1.toDouble())
                    map.putDouble("homeId", params.getDouble(HOMEID))
                    map.putString("type","onMeshAdded");
                    BridgeUtils.homeStatus(reactApplicationContext,map,params.getString(HOMEID) as String)
                }
            })
        }
    }
    /* 注销家庭下面信息变更的监听 - 홈정보 변경 모니터링 취소 */
    @ReactMethod
    fun unRegisterHomeStatusListener(params: ReadableMap) {
        if (ReactParamsCheck.checkParams(arrayOf(HOMEID), params)) {
            getHomeInstance(params.getDouble(HOMEID))
        }
    }

    /* 查询用户下面相同产品且支持群组的设备列表 - 동일 제품을 가진 장치 목록 조회 (?) */
    @ReactMethod
    fun queryDeviceListToAddGroup(params: ReadableMap, promise: Promise) {
        if (ReactParamsCheck.checkParams(arrayOf(HOMEID, PRODUCTID), params)) {
            getHomeInstance(params.getDouble(HOMEID))?.queryDeviceListToAddGroup(params.getDouble(HOMEID).toLong(),
                    params.getString(PRODUCTID),
                    object : ITuyaResultCallback<List<GroupDeviceBean>> {
                        override fun onSuccess(var1: List<GroupDeviceBean>) {
                            promise.resolve(TuyaReactUtils.parseToWritableArray(JsonUtils.toJsonArray(var1)))
                        }

                        override fun onError(var1: String, var2: String) {
                            promise.reject(var1, var2)
                        }
                    }
            )
        }
    }

    /* 查询用户下面相同产品且支持群组的设备列表 - ? */
    @ReactMethod
    fun onDestroy(params: ReadableMap) {
        if (ReactParamsCheck.checkParams(arrayOf(HOMEID), params)) {
            getHomeInstance(params.getDouble(HOMEID))?.onDestroy()
        }
    }

    fun getHomeInstance(homeId: Double): ITuyaHome? {
        return TuyaHomeSdk.newHomeInstance(homeId.toLong())
    }



    fun ITuyaGetRoomListCallback(promise: Promise): ITuyaGetRoomListCallback? {
        return object : ITuyaGetRoomListCallback {
            override fun onSuccess(var1: List<RoomBean>) {
                promise.resolve(TuyaReactUtils.parseToWritableArray(JsonUtils.toJsonArray(var1)))
            }

            override fun onError(code: String?, error: String?) {
                promise.reject(code, error)
            }
        }
    }


    fun getITuyaRoomResultCallback(promise: Promise): ITuyaRoomResultCallback? {
        return object : ITuyaRoomResultCallback {
            override fun onSuccess(p0: RoomBean) {
                promise.resolve(TuyaReactUtils.parseToWritableMap(p0))
            }

            override fun onError(code: String?, error: String?) {
                promise.reject(code, error)
            }
        }
    }

    fun getITuyaHomeResultCallback(promise: Promise): ITuyaHomeResultCallback? {
        return object : ITuyaHomeResultCallback {
            override fun onSuccess(p0: HomeBean?) {
                promise.resolve(TYCommonUtls.parseToWritableMap(p0))
            }

            override fun onError(code: String?, error: String?) {
                promise.reject(code, error)
            }
        }
    }
}

