

dateTime = () => {
    return {
        mounted() {
            let sentAt = JSON.parse(JSON.stringify(this.el.innerText))
            date = new Date(sentAt)
            this.el.innerText = timeAgo(date)
            setInterval(() => {
                date = new Date(sentAt)
                this.el.innerText = timeAgo(date)
            }, 15000)

        },
    }
}

export default dateTime
const timeAgo = (date) => {
    const seconds = Math.floor((new Date() - date) / 1000);
    const dt = " u " + date.toLocaleTimeString("en-US", { timeZone: "Europe/Belgrade", hour12: false, hour: "2-digit", minute: "2-digit" })

    let interval = Math.floor(seconds / 31536000);
    if (interval > 4) {
        return 'pre ' + interval + ' godina';
    }

    if (interval > 1) {
        return 'pre ' + interval + ' godine';
    }

    if (interval > 0) {
        return 'pre godinu dana';
    }

    interval = Math.floor(seconds / 2592000);
    if (interval > 4) {
        return 'pre ' + interval + ' meseci';
    }

    if (interval > 1) {
        return 'pre ' + interval + ' meseca';
    }

    if (interval > 0) {
        return 'pre mesec dana';
    }

    interval = Math.floor(seconds / 86400);
    if (interval > 3) {
        return 'pre ' + interval + ' dana' + dt;
    }

    if (interval > 1) {
        return 'prekjuče' + dt
    }

    if (interval > 0) {
        return 'juče' + dt
    }


    interval = Math.floor(seconds / 3600);
    if (interval > 21) {
        return 'pre ' + interval + ' sata';
    }

    if (interval > 20) {
        return 'pre ' + interval + ' sat';
    }

    if (interval > 4) {
        return 'pre ' + interval + ' sati';
    }

    if (interval > 1) {
        return 'pre ' + interval + ' sata';
    }

    interval = Math.floor(seconds / 60);
    if (interval > 45) {
        return 'pre sat vremena';
    }

    if (interval > 30) {
        return 'pre pola sata';
    }

    if (interval > 1) {
        return 'pre ' + interval + ' minuta';
    }


    if (interval > 0) {
        return 'pre minut';
    }


    return 'upravo sada';
};
