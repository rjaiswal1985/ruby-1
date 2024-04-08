public with sharing class CM_Log {
    public UCB_Log ucbLog;
    public Map<Object,Object> details;
    public CM_Log(String module, String component, Map<Object,Object> details) {
        this.ucbLog = new UCB_Log(module,component,'');
        this.details = details;
    }
}