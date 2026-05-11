/* ========================================
   Calibration Calculator - App Logic (with Positioner)
   ======================================== */

const STORAGE_KEY = 'calibration_calculator_state_v4';

// ========================================
// LOOP CALCULATOR (existing)
// ========================================
class LoopCalculator {
    constructor() {
        this.buffers = {
            inputLow: '0',
            inputHigh: '100',
            outputLow: '4',
            outputHigh: '20',
            inputValue: '0'
        };
        this.advancedEnabled = false;
        this.hysteresis = 0;
        this.resolution = 4;
        this.focusElement = 'inputValue';
        this.freshFocus = false; // Auto-clear on first keystroke
    }

    calculate() {
        const inL = parseFloat(this.buffers.inputLow) || 0;
        const inH = parseFloat(this.buffers.inputHigh) || 0;
        const outL = parseFloat(this.buffers.outputLow) || 0;
        const outH = parseFloat(this.buffers.outputHigh) || 0;
        const val = parseFloat(this.buffers.inputValue) || 0;

        if (inH === inL) return outL;
        return ((val - inL) / (inH - inL)) * (outH - outL) + outL;
    }

    calculateOutputPercentage() {
        const outL = parseFloat(this.buffers.outputLow) || 0;
        const outH = parseFloat(this.buffers.outputHigh) || 0;
        const result = this.calculate();

        if (outH === outL) return 0;
        let pct = ((result - outL) / (outH - outL)) * 100;
        return Math.min(Math.max(pct, 0), 100);
    }

    setPercentage(pct) {
        const inL = parseFloat(this.buffers.inputLow) || 0;
        const inH = parseFloat(this.buffers.inputHigh) || 0;
        const newVal = inL + (pct / 100) * (inH - inL);
        this.buffers.inputValue = newVal.toFixed(4).replace(/\.?0+$/, '');
    }

    resetDefaults() {
        this.buffers = {
            inputLow: '0',
            inputHigh: '100',
            outputLow: '4',
            outputHigh: '20',
            inputValue: '0'
        };
    }

    exportState() {
        return {
            buffers: this.buffers,
            advancedEnabled: this.advancedEnabled,
            hysteresis: this.hysteresis,
            resolution: this.resolution,
            focusElement: this.focusElement
        };
    }

    importState(state) {
        if (!state) return;
        this.buffers = state.buffers || this.buffers;
        this.advancedEnabled = state.advancedEnabled || false;
        this.hysteresis = state.hysteresis || 0;
        this.resolution = state.resolution || 4;
        this.focusElement = state.focusElement || 'inputValue';
    }
}

// ========================================
// POSITIONER CALCULATOR (new)
// ========================================
class PositionerCalculator {
    constructor() {
        this.buffers = {
            sensorZeroMa: '4',
            sensorSpanMa: '20',
            physZeroMa: '5.5',
            physSpanMa: '18.5',
            desiredZeroPct: '-1',
            desiredSpanPct: '99.5'
        };
        this.focusElement = 'physZeroMa';
        this.freshFocus = false; // Auto-clear on first keystroke
    }

    /**
     * Calculate DCS Zero and Span mA values
     * Given: Physical Zero/Span mA and Desired Zero/Span %
     * Find: mA values for 0% and 100%
     */
    calculate() {
        const zeroMa = parseFloat(this.buffers.physZeroMa) || 0;
        const spanMa = parseFloat(this.buffers.physSpanMa) || 0;
        const zeroPct = parseFloat(this.buffers.desiredZeroPct) || 0;
        const spanPct = parseFloat(this.buffers.desiredSpanPct) || 100;

        // Prevent division by zero
        if (spanPct === zeroPct) {
            return { dcsZeroMa: zeroMa, dcsSpanMa: spanMa };
        }

        // Calculate slope (mA per %)
        const slope = (spanMa - zeroMa) / (spanPct - zeroPct);

        // Calculate mA for 0% and 100%
        const dcsZeroMa = zeroMa + (0 - zeroPct) * slope;
        const dcsSpanMa = zeroMa + (100 - zeroPct) * slope;

        return { dcsZeroMa, dcsSpanMa };
    }

    resetDefaults() {
        this.buffers = {
            sensorZeroMa: '4',
            sensorSpanMa: '20',
            physZeroMa: '5.5',
            physSpanMa: '18.5',
            desiredZeroPct: '-1',
            desiredSpanPct: '99.5'
        };
    }

    exportState() {
        return {
            buffers: this.buffers,
            focusElement: this.focusElement
        };
    }

    importState(state) {
        if (!state) return;
        this.buffers = state.buffers || this.buffers;
        this.focusElement = state.focusElement || 'physZeroMa';
    }
}

// ========================================
// APP CONTROLLER
// ========================================
class AppController {
    constructor() {
        this.currentPage = 'loop';
        this.loopCalc = new LoopCalculator();
        this.posCalc = new PositionerCalculator();
        this.init();
    }

    init() {
        this.cacheElements();
        this.loadState();
        this.bindEvents();
        this.updateLoopUI();
        this.updatePositionerUI();
    }

    cacheElements() {
        // Page elements
        this.loopPage = document.getElementById('loopPage');
        this.positionerPage = document.getElementById('positionerPage');
        this.tabBtns = document.querySelectorAll('.tab-btn');

        // Loop elements
        this.loopEls = {
            inputLow: document.getElementById('inputLow'),
            inputHigh: document.getElementById('inputHigh'),
            outputLow: document.getElementById('outputLow'),
            outputHigh: document.getElementById('outputHigh'),
            currentValue: document.getElementById('currentValue'),
            resultValue: document.getElementById('resultValue'),
            barFill: document.getElementById('barFill'),
            barPercentage: document.getElementById('barPercentage'), // NEW
            inputLowWrapper: document.getElementById('inputLowWrapper'),
            inputHighWrapper: document.getElementById('inputHighWrapper'),
            outputLowWrapper: document.getElementById('outputLowWrapper'),
            outputHighWrapper: document.getElementById('outputHighWrapper'),
            mainDisplay: document.getElementById('mainDisplay'),
            currentFocusLabel: document.getElementById('currentFocusLabel'),
            keypad: document.getElementById('loopKeypad'),
            enableAdvanced: document.getElementById('enableAdvanced'),
            advancedOptions: document.getElementById('advancedOptions'),
            hysteresisVal: document.getElementById('hysteresisVal'),
            resSelect: document.getElementById('resSelect')
        };

        // Positioner elements
        this.posEls = {
            sensorZeroMa: document.getElementById('sensorZeroMa'),
            sensorSpanMa: document.getElementById('sensorSpanMa'),
            sensorZeroWrapper: document.getElementById('sensorZeroWrapper'),
            sensorSpanWrapper: document.getElementById('sensorSpanWrapper'),
            physZeroMa: document.getElementById('physZeroMa'),
            physSpanMa: document.getElementById('physSpanMa'),
            desiredZeroPct: document.getElementById('desiredZeroPct'),
            desiredSpanPct: document.getElementById('desiredSpanPct'),
            dcsZeroMa: document.getElementById('dcsZeroMa'),
            dcsSpanMa: document.getElementById('dcsSpanMa'),
            physZeroWrapper: document.getElementById('physZeroWrapper'),
            physSpanWrapper: document.getElementById('physSpanWrapper'),
            desiredZeroWrapper: document.getElementById('desiredZeroWrapper'),
            desiredSpanWrapper: document.getElementById('desiredSpanWrapper'),
            keypad: document.getElementById('positionerKeypad'),
            // 2-Zone bar graph elements
            zeroMarker: document.getElementById('zeroMarker'),
            spanMarker: document.getElementById('spanMarker'),
            zeroPointDisplay: document.getElementById('zeroPointDisplay'),
            spanPointDisplay: document.getElementById('spanPointDisplay')
        };
    }

    bindEvents() {
        // Tab switching
        this.tabBtns.forEach(btn => {
            btn.addEventListener('click', () => this.switchPage(btn.dataset.page));
        });

        // Loop focus
        ['inputLow', 'inputHigh', 'outputLow', 'outputHigh'].forEach(id => {
            document.getElementById(id + 'Wrapper').addEventListener('click', () => {
                this.loopCalc.focusElement = id;
                this.loopCalc.freshFocus = true; // Set fresh focus
                this.updateLoopFocusStyles();
                this.vibrate(10);
            });
        });
        this.loopEls.mainDisplay.addEventListener('click', () => {
            this.loopCalc.focusElement = 'inputValue';
            this.loopCalc.freshFocus = true; // Set fresh focus
            this.updateLoopFocusStyles();
            this.vibrate(10);
        });

        // Positioner wrappers
        this.posEls.sensorZeroWrapper?.addEventListener('click', () => this.setPositionerFocus('sensorZeroMa'));
        this.posEls.sensorSpanWrapper?.addEventListener('click', () => this.setPositionerFocus('sensorSpanMa'));
        this.posEls.physZeroWrapper?.addEventListener('click', () => this.setPositionerFocus('physZeroMa'));
        this.posEls.physSpanWrapper?.addEventListener('click', () => this.setPositionerFocus('physSpanMa'));
        this.posEls.desiredZeroWrapper?.addEventListener('click', () => this.setPositionerFocus('desiredZeroPct'));
        this.posEls.desiredSpanWrapper?.addEventListener('click', () => this.setPositionerFocus('desiredSpanPct'));

        // Loop keypad
        this.loopEls.keypad.addEventListener('click', (e) => {
            const key = e.target.closest('.key');
            if (!key) return;
            const action = key.dataset.action;
            const value = key.dataset.value;
            const keyChar = key.dataset.key;

            if (action === 'pct') {
                this.loopCalc.setPercentage(parseFloat(value));
                this.updateLoopUI();
                this.vibrate(10);
                return;
            }
            this.handleLoopKey(keyChar);
            this.vibrate(5);
        });

        // Positioner keypad
        this.posEls.keypad.addEventListener('click', (e) => {
            const key = e.target.closest('.key');
            if (!key) return;
            this.handlePositionerKey(key.dataset.key);
            this.vibrate(5);
        });

        // Advanced toggle
        this.loopEls.enableAdvanced?.addEventListener('change', (e) => {
            this.loopCalc.advancedEnabled = e.target.checked;
            this.loopEls.advancedOptions.classList.toggle('disabled', !e.target.checked);
            this.saveState();
        });

        this.loopEls.hysteresisVal?.addEventListener('input', (e) => {
            this.loopCalc.hysteresis = parseFloat(e.target.value) || 0;
            this.saveState();
        });

        this.loopEls.resSelect?.addEventListener('change', (e) => {
            this.loopCalc.resolution = parseInt(e.target.value);
            this.saveState();
            this.updateLoopUI();
        });
    }

    switchPage(page) {
        this.currentPage = page;
        this.tabBtns.forEach(btn => {
            btn.classList.toggle('active', btn.dataset.page === page);
        });
        this.loopPage.classList.toggle('hidden', page !== 'loop');
        this.positionerPage.classList.toggle('hidden', page !== 'positioner');
        this.saveState();
    }

    setPositionerFocus(field) {
        this.posCalc.focusElement = field;
        this.posCalc.freshFocus = true; // Set fresh focus
        this.updatePositionerFocusStyles();
        this.vibrate(10);
    }

    handleLoopKey(key) {
        const focus = this.loopCalc.focusElement;
        let buffer = this.loopCalc.buffers[focus];

        switch (key) {
            case 'clearAll':
                this.loopCalc.resetDefaults();
                this.loopCalc.freshFocus = false;
                break;
            case 'clear':
                this.loopCalc.buffers[focus] = '0';
                this.loopCalc.freshFocus = false;
                break;
            case 'backspace':
                this.loopCalc.buffers[focus] = buffer.length > 1 ? buffer.slice(0, -1) : '0';
                this.loopCalc.freshFocus = false;
                break;
            case 'negate':
                if (buffer.startsWith('-')) {
                    this.loopCalc.buffers[focus] = buffer.slice(1);
                } else if (buffer !== '0') {
                    this.loopCalc.buffers[focus] = '-' + buffer;
                }
                this.loopCalc.freshFocus = false;
                break;
            case 'enter':
                break;
            case '.':
                if (this.loopCalc.freshFocus) {
                    this.loopCalc.buffers[focus] = '0.';
                } else if (!buffer.includes('.')) {
                    this.loopCalc.buffers[focus] += '.';
                }
                this.loopCalc.freshFocus = false;
                break;
            default:
                if (/^\d$/.test(key)) {
                    if (this.loopCalc.freshFocus) {
                        // First keystroke: replace existing value
                        this.loopCalc.buffers[focus] = key;
                    } else {
                        this.loopCalc.buffers[focus] = buffer === '0' ? key : buffer + key;
                    }
                    this.loopCalc.freshFocus = false;
                }
        }
        this.updateLoopUI();
        this.saveState();
    }

    handlePositionerKey(key) {
        const focus = this.posCalc.focusElement;
        let buffer = this.posCalc.buffers[focus];

        switch (key) {
            case 'clearAll':
                this.posCalc.resetDefaults();
                this.posCalc.freshFocus = false;
                break;
            case 'clear':
                this.posCalc.buffers[focus] = '0';
                this.posCalc.freshFocus = false;
                break;
            case 'backspace':
                this.posCalc.buffers[focus] = buffer.length > 1 ? buffer.slice(0, -1) : '0';
                this.posCalc.freshFocus = false;
                break;
            case 'negate':
                if (buffer.startsWith('-')) {
                    this.posCalc.buffers[focus] = buffer.slice(1);
                } else if (buffer !== '0') {
                    this.posCalc.buffers[focus] = '-' + buffer;
                }
                this.posCalc.freshFocus = false;
                break;
            case 'enter':
                break;
            case '.':
                if (this.posCalc.freshFocus) {
                    this.posCalc.buffers[focus] = '0.';
                } else if (!buffer.includes('.')) {
                    this.posCalc.buffers[focus] += '.';
                }
                this.posCalc.freshFocus = false;
                break;
            default:
                if (/^\d$/.test(key)) {
                    if (this.posCalc.freshFocus) {
                        // First keystroke: replace existing value
                        this.posCalc.buffers[focus] = key;
                    } else {
                        this.posCalc.buffers[focus] = buffer === '0' ? key : buffer + key;
                    }
                    this.posCalc.freshFocus = false;
                }
        }
        this.updatePositionerUI();
        this.saveState();
    }

    updateLoopUI() {
        const calc = this.loopCalc;
        this.loopEls.inputLow.value = calc.buffers.inputLow;
        this.loopEls.inputHigh.value = calc.buffers.inputHigh;
        this.loopEls.outputLow.value = calc.buffers.outputLow;
        this.loopEls.outputHigh.value = calc.buffers.outputHigh;
        this.loopEls.currentValue.textContent = calc.buffers.inputValue;

        const result = calc.calculate();
        this.loopEls.resultValue.textContent = result.toFixed(calc.resolution).replace(/\.?0+$/, '');

        const pct = calc.calculateOutputPercentage();
        this.loopEls.barFill.style.width = `${pct}%`;

        // Update percentage display
        if (this.loopEls.barPercentage) {
            this.loopEls.barPercentage.textContent = `${pct.toFixed(1)}%`;
        }

        this.updateLoopFocusStyles();
    }

    updateLoopFocusStyles() {
        const id = this.loopCalc.focusElement;
        [this.loopEls.inputLowWrapper, this.loopEls.inputHighWrapper,
        this.loopEls.outputLowWrapper, this.loopEls.outputHighWrapper,
        this.loopEls.mainDisplay].forEach(el => el?.classList.remove('active'));

        const labelMap = {
            inputLow: 'INPUT LOW RANGE',
            inputHigh: 'INPUT HIGH RANGE',
            outputLow: 'OUTPUT LOW RANGE',
            outputHigh: 'OUTPUT HIGH RANGE',
            inputValue: 'INPUT VALUE'
        };
        this.loopEls.currentFocusLabel.textContent = labelMap[id] || 'INPUT VALUE';

        if (id === 'inputValue') {
            this.loopEls.mainDisplay?.classList.add('active');
        } else {
            document.getElementById(id + 'Wrapper')?.classList.add('active');
        }
    }

    updatePositionerUI() {
        const calc = this.posCalc;
        // Display sensor mA range
        if (this.posEls.sensorZeroMa) this.posEls.sensorZeroMa.value = calc.buffers.sensorZeroMa;
        if (this.posEls.sensorSpanMa) this.posEls.sensorSpanMa.value = calc.buffers.sensorSpanMa;

        this.posEls.physZeroMa.value = calc.buffers.physZeroMa;
        this.posEls.physSpanMa.value = calc.buffers.physSpanMa;
        this.posEls.desiredZeroPct.value = calc.buffers.desiredZeroPct;
        this.posEls.desiredSpanPct.value = calc.buffers.desiredSpanPct;

        const result = calc.calculate();
        this.posEls.dcsZeroMa.textContent = result.dcsZeroMa.toFixed(2);
        this.posEls.dcsSpanMa.textContent = result.dcsSpanMa.toFixed(2);

        // Update 2-zone bar graph
        const zeroPct = parseFloat(calc.buffers.desiredZeroPct) || 0;
        const spanPct = parseFloat(calc.buffers.desiredSpanPct) || 100;

        // Update point displays
        if (this.posEls.zeroPointDisplay) {
            this.posEls.zeroPointDisplay.textContent = `${zeroPct}%`;
        }
        if (this.posEls.spanPointDisplay) {
            this.posEls.spanPointDisplay.textContent = `${spanPct}%`;
        }

        // Position zero marker in left zone (-5 to 5 range)
        // Map zeroPct to position: -5 = 0%, 5 = 100%
        if (this.posEls.zeroMarker) {
            const zeroPos = Math.max(0, Math.min(100, ((zeroPct - (-5)) / 10) * 100));
            this.posEls.zeroMarker.style.left = `${zeroPos}%`;
        }

        // Position span marker in right zone (95 to 105 range)
        // Map spanPct to position: 95 = 0%, 105 = 100%
        if (this.posEls.spanMarker) {
            const spanPos = Math.max(0, Math.min(100, ((spanPct - 95) / 10) * 100));
            this.posEls.spanMarker.style.left = `${spanPos}%`;
        }

        this.updatePositionerFocusStyles();
    }

    updatePositionerFocusStyles() {
        const id = this.posCalc.focusElement;
        [this.posEls.sensorZeroWrapper, this.posEls.sensorSpanWrapper,
        this.posEls.physZeroWrapper, this.posEls.physSpanWrapper,
        this.posEls.desiredZeroWrapper, this.posEls.desiredSpanWrapper]
            .forEach(el => el?.classList.remove('active'));

        const wrapperMap = {
            sensorZeroMa: this.posEls.sensorZeroWrapper,
            sensorSpanMa: this.posEls.sensorSpanWrapper,
            physZeroMa: this.posEls.physZeroWrapper,
            physSpanMa: this.posEls.physSpanWrapper,
            desiredZeroPct: this.posEls.desiredZeroWrapper,
            desiredSpanPct: this.posEls.desiredSpanWrapper
        };
        wrapperMap[id]?.classList.add('active');
    }

    saveState() {
        localStorage.setItem(STORAGE_KEY, JSON.stringify({
            currentPage: this.currentPage,
            loop: this.loopCalc.exportState(),
            positioner: this.posCalc.exportState()
        }));
    }

    loadState() {
        const raw = localStorage.getItem(STORAGE_KEY);
        if (raw) {
            const data = JSON.parse(raw);
            this.currentPage = data.currentPage || 'loop';
            this.loopCalc.importState(data.loop);
            this.posCalc.importState(data.positioner);

            // Apply UI state
            this.switchPage(this.currentPage);
            if (this.loopEls.enableAdvanced) {
                this.loopEls.enableAdvanced.checked = this.loopCalc.advancedEnabled;
                this.loopEls.advancedOptions?.classList.toggle('disabled', !this.loopCalc.advancedEnabled);
            }
            if (this.loopEls.hysteresisVal) this.loopEls.hysteresisVal.value = this.loopCalc.hysteresis;
            if (this.loopEls.resSelect) this.loopEls.resSelect.value = this.loopCalc.resolution;
        }
    }

    vibrate(ms) {
        if (navigator.vibrate) navigator.vibrate(ms);
    }
}

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    new AppController();
    console.log('Calibration Calculator v4 (with Positioner) initialized');
});

// Service Worker registration — disabled on localhost file:// for easier dev.
if ('serviceWorker' in navigator && location.protocol.startsWith('http')) {
    window.addEventListener('load', () => {
        navigator.serviceWorker
            .register('sw.js')
            .then(reg => {
                reg.addEventListener('updatefound', () => {
                    const installing = reg.installing;
                    if (!installing) return;
                    installing.addEventListener('statechange', () => {
                        if (installing.state === 'installed' && navigator.serviceWorker.controller) {
                            console.log('[SW] New version available — reload to apply.');
                        }
                    });
                });
            })
            .catch(err => console.warn('[SW] registration failed:', err));
    });
}

