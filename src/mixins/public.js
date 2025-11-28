import axios from "axios";
import { getDevContainerServerHostname, isDevContainer, getBasePath } from "../util-frontend";

const env = process.env.NODE_ENV || "production";

// Initialize axios baseURL from <base href> tag - simplest approach
const initAxiosBaseURL = () => {
    const baseTag = document.querySelector("head base");
    let basePath = "";

    if (baseTag && baseTag.getAttribute("href")) {
        basePath = baseTag.getAttribute("href");
        // Remove trailing slash to avoid double slashes
        basePath = basePath.replace(/\/$/, "");
    }

    if (env === "development" && isDevContainer()) {
        axios.defaults.baseURL = location.protocol + "//" + getDevContainerServerHostname() + basePath;
    } else if (env === "development" || localStorage.dev === "dev") {
        axios.defaults.baseURL = location.protocol + "//" + location.hostname + ":3001" + basePath;
    } else {
        // In production, use base path directly (Axios will prepend it to relative URLs)
        axios.defaults.baseURL = basePath || undefined;
    }
    console.log("[Axios] BaseURL set to:", axios.defaults.baseURL, "Base path:", basePath);
};

// Initialize immediately - base tag should be in HTML when script loads
initAxiosBaseURL();

// Also re-initialize after DOM is ready to ensure it's correct
if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", () => {
        setTimeout(initAxiosBaseURL, 50);
    });
} else {
    // DOM already ready, re-initialize after a short delay
    setTimeout(initAxiosBaseURL, 50);
}

export default {
    data() {
        return {
            publicGroupList: [],
        };
    },
    computed: {
        publicMonitorList() {
            let result = {};

            for (let group of this.publicGroupList) {
                for (let monitor of group.monitorList) {
                    result[monitor.id] = monitor;
                }
            }
            return result;
        },

        publicLastHeartbeatList() {
            let result = {};

            for (let monitorID in this.publicMonitorList) {
                if (this.lastHeartbeatList[monitorID]) {
                    result[monitorID] = this.lastHeartbeatList[monitorID];
                }
            }

            return result;
        },

        baseURL() {
            if (this.$root.info.primaryBaseURL) {
                return this.$root.info.primaryBaseURL;
            }

            if (env === "development" || localStorage.dev === "dev") {
                return axios.defaults.baseURL;
            } else {
                // Include base path in baseURL
                const basePath = getBasePath();
                return location.protocol + "//" + location.host + basePath;
            }
        },
    }
};
