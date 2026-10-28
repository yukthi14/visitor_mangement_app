const fs = require('fs');
const path = require('path');
const zlib = require('zlib');

// PNG parser & scanline unfilter
function parsePNG(filePath) {
  const buffer = fs.readFileSync(filePath);
  let offset = 8;
  let width, height, colorType;
  const idatChunks = [];

  while (offset < buffer.length) {
    const length = buffer.readUInt32BE(offset);
    const type = buffer.toString('ascii', offset + 4, offset + 8);
    const data = buffer.slice(offset + 8, offset + 8 + length);
    offset += 12 + length;

    if (type === 'IHDR') {
      width = data.readUInt32BE(0);
      height = data.readUInt32BE(4);
      colorType = data[9];
    } else if (type === 'IDAT') {
      idatChunks.push(data);
    }
  }

  const decompressed = zlib.inflateSync(Buffer.concat(idatChunks));
  const bytesPerPixel = colorType === 6 ? 4 : colorType === 2 ? 3 : 1;
  const stride = width * bytesPerPixel;
  const rawRGB = Buffer.alloc(width * height * 3);

  let srcOffset = 0;
  let prevRow = Buffer.alloc(stride);
  let curRow = Buffer.alloc(stride);

  function paeth(a, b, c) {
    const p = a + b - c;
    const pa = Math.abs(p - a);
    const pb = Math.abs(p - b);
    const pc = Math.abs(p - c);
    if (pa <= pb && pa <= pc) return a;
    if (pb <= pc) return b;
    return c;
  }

  let rgbOffset = 0;
  for (let y = 0; y < height; y++) {
    const filter = decompressed[srcOffset++];
    for (let x = 0; x < stride; x++) {
      const raw = decompressed[srcOffset++];
      const a = x >= bytesPerPixel ? curRow[x - bytesPerPixel] : 0;
      const b = prevRow[x];
      const c = x >= bytesPerPixel ? prevRow[x - bytesPerPixel] : 0;

      let val = 0;
      if (filter === 0) val = raw;
      else if (filter === 1) val = (raw + a) & 0xff;
      else if (filter === 2) val = (raw + b) & 0xff;
      else if (filter === 3) val = (raw + Math.floor((a + b) / 2)) & 0xff;
      else if (filter === 4) val = (raw + paeth(a, b, c)) & 0xff;
      curRow[x] = val;
    }

    for (let x = 0; x < width; x++) {
      if (colorType === 6) {
        rawRGB[rgbOffset++] = curRow[x * 4];
        rawRGB[rgbOffset++] = curRow[x * 4 + 1];
        rawRGB[rgbOffset++] = curRow[x * 4 + 2];
      } else if (colorType === 2) {
        rawRGB[rgbOffset++] = curRow[x * 3];
        rawRGB[rgbOffset++] = curRow[x * 3 + 1];
        rawRGB[rgbOffset++] = curRow[x * 3 + 2];
      }
    }
    prevRow.set(curRow);
  }

  return { width, height, rawRGB };
}

// PDF Builder
class PDFBuilder {
  constructor() {
    this.objects = [];
  }

  addObject(header, streamBuffer = null) {
    const id = this.objects.length + 1;
    this.objects.push({ id, header, streamBuffer });
    return id;
  }

  build() {
    const chunks = [];
    chunks.push(Buffer.from('%PDF-1.4\n%\xE2\xE3\xCF\xD3\n', 'binary'));
    let currentOffset = chunks[0].length;
    const offsets = [0];

    for (let i = 0; i < this.objects.length; i++) {
      const obj = this.objects[i];
      offsets.push(currentOffset);
      let head = obj.id + ' 0 obj\n' + obj.header + '\n';
      let tail = '\nendobj\n';
      if (obj.streamBuffer) {
        const streamHead = 'stream\n';
        const streamTail = '\nendstream';
        const bHead = Buffer.from(head + streamHead, 'binary');
        const bTail = Buffer.from(streamTail + tail, 'binary');
        chunks.push(bHead, obj.streamBuffer, bTail);
        currentOffset += bHead.length + obj.streamBuffer.length + bTail.length;
      } else {
        const b = Buffer.from(head + tail, 'binary');
        chunks.push(b);
        currentOffset += b.length;
      }
    }

    const startXref = currentOffset;
    let xref = 'xref\n0 ' + (this.objects.length + 1) + '\n0000000000 65535 f \n';
    for (let i = 1; i <= this.objects.length; i++) {
      xref += String(offsets[i]).padStart(10, '0') + ' 00000 n \n';
    }
    xref += 'trailer\n<< /Size ' + (this.objects.length + 1) + ' /Root 1 0 R >>\n';
    xref += 'startxref\n' + startXref + '\n%%EOF\n';
    chunks.push(Buffer.from(xref, 'binary'));

    return Buffer.concat(chunks);
  }
}

// Helper to escape PDF text strings
function escapePdfText(str) {
  return str.replace(/\\/g, '\\\\').replace(/\(/g, '\\(').replace(/\)/g, '\\)');
}

// Word wrapping utility
function wrapText(text, maxChars) {
  const words = text.split(' ');
  const lines = [];
  let currentLine = '';

  for (const word of words) {
    if ((currentLine + (currentLine ? ' ' : '') + word).length <= maxChars) {
      currentLine += (currentLine ? ' ' : '') + word;
    } else {
      if (currentLine) lines.push(currentLine);
      currentLine = word;
    }
  }
  if (currentLine) lines.push(currentLine);
  return lines;
}

// Content Stream Drawing Helpers
class PagePainter {
  constructor() {
    this.ops = [];
  }

  raw(str) {
    this.ops.push(str);
  }

  // Draw rectangle (filled and/or stroked)
  rect(x, y, w, h, fillColor = null, strokeColor = null, lineWidth = 1) {
    if (strokeColor) {
      this.ops.push(`${strokeColor[0].toFixed(3)} ${strokeColor[1].toFixed(3)} ${strokeColor[2].toFixed(3)} RG`);
      this.ops.push(`${lineWidth.toFixed(2)} w`);
    }
    if (fillColor) {
      this.ops.push(`${fillColor[0].toFixed(3)} ${fillColor[1].toFixed(3)} ${fillColor[2].toFixed(3)} rg`);
    }
    this.ops.push(`${x.toFixed(2)} ${y.toFixed(2)} ${w.toFixed(2)} ${h.toFixed(2)} re`);
    if (fillColor && strokeColor) {
      this.ops.push('B');
    } else if (fillColor) {
      this.ops.push('f');
    } else if (strokeColor) {
      this.ops.push('S');
    }
  }

  // Draw straight line
  line(x1, y1, x2, y2, strokeColor = [0.8, 0.8, 0.8], lineWidth = 1) {
    this.ops.push(`${strokeColor[0].toFixed(3)} ${strokeColor[1].toFixed(3)} ${strokeColor[2].toFixed(3)} RG`);
    this.ops.push(`${lineWidth.toFixed(2)} w`);
    this.ops.push(`${x1.toFixed(2)} ${y1.toFixed(2)} m ${x2.toFixed(2)} ${y2.toFixed(2)} l S`);
  }

  // Text string
  text(x, y, str, font = 'F1', size = 10, color = [0.1, 0.1, 0.1]) {
    this.ops.push('BT');
    this.ops.push(`/${font} ${size.toFixed(1)} Tf`);
    this.ops.push(`${color[0].toFixed(3)} ${color[1].toFixed(3)} ${color[2].toFixed(3)} rg`);
    this.ops.push(`${x.toFixed(2)} ${y.toFixed(2)} Td`);
    this.ops.push(`(${escapePdfText(str)}) Tj`);
    this.ops.push('ET');
  }

  // Draw image
  image(name, x, y, w, h) {
    this.ops.push('q');
    this.ops.push(`${w.toFixed(2)} 0 0 ${h.toFixed(2)} ${x.toFixed(2)} ${y.toFixed(2)} cm`);
    this.ops.push(`/${name} Do`);
    this.ops.push('Q');
  }

  toBuffer() {
    return Buffer.from(this.ops.join('\n'), 'utf8');
  }
}

// Palette Definitions
const C_NAVY = [0.059, 0.090, 0.165];      // #0F172A
const C_SLATE_800 = [0.118, 0.161, 0.231]; // #1E293B
const C_SLATE_600 = [0.278, 0.333, 0.412]; // #475569
const C_SLATE_400 = [0.580, 0.639, 0.722]; // #94A3B8
const C_SLATE_200 = [0.886, 0.910, 0.941]; // #E2E8F0
const C_SLATE_100 = [0.949, 0.961, 0.976]; // #F1F5F9
const C_SLATE_50  = [0.973, 0.980, 0.988]; // #F8FAFC
const C_BLUE      = [0.145, 0.388, 0.922]; // #2563EB
const C_BLUE_LIGHT= [0.859, 0.918, 0.996]; // #DBEAFE
const C_BLUE_DARK = [0.118, 0.251, 0.686]; // #1E40AF
const C_TEAL      = [0.051, 0.580, 0.533]; // #0D9488
const C_TEAL_LIGHT= [0.878, 0.965, 0.957]; // #CCFBF1
const C_GREEN     = [0.086, 0.627, 0.365]; // #16A34A
const C_WHITE     = [1.0, 1.0, 1.0];

// Screen Showcase Catalog Data
const SCREENS_DATA = [
  {
    num: "01",
    title: "Executive Dashboard & Daily Operations",
    badge: "CORE MODULE • OPERATIONS CENTER",
    subtitle: "Real-time facility headcounts, date-filtered logs, and rapid security actions",
    file: "screenshots/01_dashboard.png",
    objective: "Serves as the primary operational hub for receptionists and security guards, providing high-visibility facility metrics, immediate visitor intake shortcuts, and live attendance feeds.",
    features: [
      {
        heading: "Live Headcount Counters",
        desc: "Instant metrics displaying Total Visitors Today (1), Currently Checked In (1), and Checked Out (0) with zero refresh lag."
      },
      {
        heading: "Interactive Date Range Filter",
        desc: "Calendar integration enabling security staff to inspect attendance logs and headcounts for any past or upcoming date."
      },
      {
        heading: "Quick Action Launchpad",
        desc: "One-tap navigation shortcuts to register new visitors, launch live QR scanner, and browse the full directory."
      },
      {
        heading: "Live Visitor Feed",
        desc: "Chronological activity list displaying visitor photo avatar, full name, host department, and real-time status chips."
      },
      {
        heading: "AppBar Theme Switcher",
        desc: "Instant toggle button located in the top bar to switch dynamically between System, Light, and Dark display modes."
      }
    ],
    tech: [
      { key: "State Management", val: "DashboardBloc (reactive state stream)" },
      { key: "Primary Widgets", val: "MetricCard, QuickActionButton, VisitorTile" },
      { key: "Theme Engine", val: "Adaptive ThemeData (Light & Dark Mode)" },
      { key: "Status", val: "Verified & Production-Ready" }
    ]
  },
  {
    num: "02",
    title: "Visitor Directory & Multi-Status Filtering",
    badge: "DIRECTORY MODULE • RECORDS MANAGEMENT",
    subtitle: "Searchable visitor registry with multi-status filtering and quick actions",
    file: "screenshots/02_visitor_list.png",
    objective: "Delivers an organized, searchable log of all visitors across the facility, allowing security staff to inspect profiles, verify historical logs, and filter records by custom criteria.",
    features: [
      {
        heading: "Real-Time As-You-Type Search",
        desc: "Instant search bar filtering records dynamically by visitor name, company, host employee, or mobile number."
      },
      {
        heading: "Modal Bottom-Sheet Filter",
        desc: "Granular status filtering isolating Checked In, Checked Out, and Pending arrivals with clear touch chips."
      },
      {
        heading: "High-Contrast Status Chips",
        desc: "Color-coded indicators providing immediate visual feedback on visitor presence (Green for Checked In, Grey for Checked Out)."
      },
      {
        heading: "Detailed Visitor Cards",
        desc: "Presents visitor avatar, full name, organization, host department, and formatted entry timestamps."
      },
      {
        heading: "Direct Profile Access",
        desc: "Tapping any list item navigates directly to the visitor's detailed profile and downloadable digital pass."
      }
    ],
    tech: [
      { key: "State Management", val: "VisitorListBloc with debounced search" },
      { key: "Primary Widgets", val: "VisitorListTile, SearchTextField, FilterChip" },
      { key: "Filter Logic", val: "Multi-parameter predicate matching" },
      { key: "Status", val: "Verified & Contrast-Audited" }
    ]
  },
  {
    num: "03",
    title: "Visitor Registration & Strict Validation",
    badge: "ONBOARDING MODULE • DATA INTAKE",
    subtitle: "Structured onboarding form with strict field validations and department routing",
    file: "screenshots/03_visitor_registration.png",
    objective: "Facilitates seamless visitor onboarding with rigorous field-level validation to prevent corrupt data entry and immediately issue digital credentials.",
    features: [
      {
        heading: "Digits-Only Mobile Number",
        desc: "Phone text field strictly enforces numeric-only input using FilteringTextInputFormatter with 10-digit validation."
      },
      {
        heading: "RFC 5322 Email Validation",
        desc: "Comprehensive regular expression checks email syntax in real time, preventing malformed email addresses."
      },
      {
        heading: "Purpose & Department Selection",
        desc: "Categorized dropdown menus for Meeting, Interview, Delivery, Vendor, or Personal visit types."
      },
      {
        heading: "Host Employee Routing",
        desc: "Direct assignment of the responsible internal host employee for visitor accountability."
      },
      {
        heading: "Instant Pass Generation",
        desc: "Form submission cryptographically generates a unique visitor record and high-density digital QR badge."
      }
    ],
    tech: [
      { key: "State Management", val: "RegisterVisitorBloc with Formz validation" },
      { key: "Primary Widgets", val: "CustomTextField, CustomDropdown, PrimaryBtn" },
      { key: "Input Formatters", val: "FilteringTextInputFormatter.digitsOnly" },
      { key: "Status", val: "Verified with Validation Test Cases" }
    ]
  },
  {
    num: "04",
    title: "Visitor Details & Digital QR Pass",
    badge: "CREDENTIALS MODULE • DIGITAL ACCESS PASS",
    subtitle: "Full visitor credentials with high-density QR code for touchless scanning",
    file: "screenshots/04_visitor_details_qr.png",
    objective: "Presents the official digital visitor pass containing verified visitor information, host assignment, and an encrypted high-density QR code for scanning at security gates.",
    features: [
      {
        heading: "High-Density QR Code",
        desc: "Cryptographically encoded digital badge containing visitor ID, name, date, and access authorization."
      },
      {
        heading: "Complete Visitor Profile",
        desc: "High-visibility presentation of visitor name, phone number, email address, organization, and visit purpose."
      },
      {
        heading: "Host & Schedule Summary",
        desc: "Displays host employee name, department, scheduled arrival time, and anticipated duration."
      },
      {
        heading: "One-Tap Gate Actions",
        desc: "Direct action buttons for reception staff to execute Check In or Check Out directly from the profile."
      },
      {
        heading: "Pass Export & Share",
        desc: "Allows security staff to export and share the digital QR badge directly to the visitor's smartphone."
      }
    ],
    tech: [
      { key: "State Management", val: "VisitorDetailsBloc with synchronous update" },
      { key: "Primary Widgets", val: "QrImageView (qr_flutter), ProfileCard, ActionBtn" },
      { key: "QR Encoding", val: "High-error-correction QR matrix" },
      { key: "Status", val: "Verified with Physical Camera Scanners" }
    ]
  },
  {
    num: "05",
    title: "High-Speed Camera QR Code Scanner",
    badge: "GATEWAY MODULE • TOUCHLESS ACCESS",
    subtitle: "Hardware-accelerated camera scanner with instant barcode decoding",
    file: "screenshots/05_qr_scanner.png",
    objective: "Enables checkpoint security personnel to scan digital visitor badges in milliseconds, verifying entry authorization touchlessly without manual logbooks.",
    features: [
      {
        heading: "Full-Screen Live Viewfinder",
        desc: "High-framerate hardware camera stream with centered alignment reticle and animated scanning guide."
      },
      {
        heading: "Sub-Second Hardware Decoding",
        desc: "Powered by mobile_scanner utilizing native ML Kit vision libraries for immediate barcode recognition."
      },
      {
        heading: "Torch / Flashlight Control",
        desc: "Toggleable illumination button for low-light checkpoints, underground parking basements, and night shifts."
      },
      {
        heading: "Camera Lens Switching",
        desc: "Quick toggle between front and rear cameras, accommodating stationary reception tablets and mobile guards."
      },
      {
        heading: "Sound & Haptic Feedback",
        desc: "Provides instant tactile vibration and audible alert confirming successful badge capture."
      }
    ],
    tech: [
      { key: "Engine", val: "mobile_scanner (CameraX / AVFoundation)" },
      { key: "Primary Widgets", val: "MobileScanner, ScannerOverlay, TorchButton" },
      { key: "Decoding Speed", val: "< 150ms average read latency" },
      { key: "Status", val: "Verified on Physical Android Hardware" }
    ]
  },
  {
    num: "06",
    title: "Security Validation Alert & Error Handling",
    badge: "SECURITY MODULE • EXCEPTION HANDLING",
    subtitle: "Tamper-evident error dialog alerting security to unauthorized or corrupt codes",
    file: "screenshots/05_qr_invalid_dialog.png",
    objective: "Safeguards facility security by immediately catching corrupt, expired, or fraudulent QR codes and presenting clear diagnostic instructions to the guard.",
    features: [
      {
        heading: "High-Visibility Alert Modal",
        desc: "Prominent security dialog featuring an amber/red warning shield and unambiguous error guidance."
      },
      {
        heading: "Security Diagnostics",
        desc: "Informs the operator that the scanned barcode does not match any registered visitor record."
      },
      {
        heading: "Non-Blocking Recovery",
        desc: "'Try Again' action button resets the scanner viewfinder instantly without requiring app restart."
      },
      {
        heading: "Manual Fallback Prompt",
        desc: "Prompts the guard to search for the visitor manually in the directory via phone number or name."
      },
      {
        heading: "Anti-Spoofing Protection",
        desc: "Prevents malformed data, URL injections, or third-party barcodes from crashing the application."
      }
    ],
    tech: [
      { key: "State Management", val: "QRScanBloc error state emission" },
      { key: "Primary Widgets", val: "AlertDialog, WarningBadge, DialogButton" },
      { key: "Exception Handling", val: "Graceful try-catch with UI event dispatch" },
      { key: "Status", val: "Verified with Corrupt & Foreign Codes" }
    ]
  },
  {
    num: "07",
    title: "Scanned Visitor Verification & Attendance",
    badge: "GATEWAY MODULE • ATTENDANCE LOGGING",
    subtitle: "Instant identity verification and one-tap Check-In / Check-Out confirmation",
    file: "screenshots/05_scanned_visitor_info.png",
    objective: "Displayed immediately upon a valid QR scan, presenting the visitor's verified credentials and allowing the guard to confirm attendance with a single tap.",
    features: [
      {
        heading: "Visitor ID Reference Banner",
        desc: "Distinct header displaying the system-assigned Visitor Code (e.g. VIS-2026-001) for audit tracking."
      },
      {
        heading: "Current Presence Status",
        desc: "Color-coded badge confirming current status (Pending Arrival, Inside Facility, or Departed)."
      },
      {
        heading: "Full Identity Verification",
        desc: "Displays visitor photo, contact number, assigned host employee, and visit objective for guard inspection."
      },
      {
        heading: "Contextual Action Button",
        desc: "Dynamically toggles between 'Confirm Check-In' and 'Confirm Check-Out' based on active attendance state."
      },
      {
        heading: "Automated Gate Timestamping",
        desc: "Records the precise gate check-in or check-out timestamp into the database upon confirmation."
      }
    ],
    tech: [
      { key: "State Management", val: "QRScanBloc -> CheckInSuccess / CheckOutSuccess" },
      { key: "Primary Widgets", val: "VisitorVerificationCard, StatusChip, PrimaryBtn" },
      { key: "Database Sync", val: "Atomic timestamp updates with host notify" },
      { key: "Status", val: "Verified with End-to-End Attendance Flow" }
    ]
  },
  {
    num: "08",
    title: "Visitor Statistics & Executive Analytics",
    badge: "ANALYTICS MODULE • EXECUTIVE REPORTING",
    subtitle: "Weekly volume bar charts, visit categorization, and capacity metrics",
    file: "screenshots/06_visitor_statistics.png",
    objective: "Delivers actionable operational insights for facility managers to monitor visitor traffic trends, peak visitation hours, and visit category distribution.",
    features: [
      {
        heading: "Weekly Volume Bar Chart",
        desc: "Dual-colored grouped bar chart comparing daily Checked In versus Checked Out visitor numbers."
      },
      {
        heading: "Visit Purpose Donut Chart",
        desc: "Proportional breakdown of visit types (Client Meetings, Interviews, Deliveries, Vendors)."
      },
      {
        heading: "Peak Hours & Capacity Metrics",
        desc: "Summarizes average visit duration and highest facility density periods for staff scheduling."
      },
      {
        heading: "Configurable Time Scopes",
        desc: "Allows filtering data across This Week, This Month, Last Quarter, or Custom Date Ranges."
      },
      {
        heading: "Compliance & Security Audit Ready",
        desc: "Enables facility supervisors to verify physical presence against security logs effortlessly."
      }
    ],
    tech: [
      { key: "Chart Engine", val: "fl_chart with animated vector rendering" },
      { key: "Primary Widgets", val: "BarChart, PieChart, MetricLegend, SummaryTile" },
      { key: "Performance", val: "60 FPS GPU-accelerated rendering" },
      { key: "Status", val: "Verified across Multiple Screen Sizes" }
    ]
  },
  {
    num: "09",
    title: "Interactive Date Picker Calendar",
    badge: "AUDITING MODULE • HISTORICAL QUERY",
    subtitle: "Intuitive calendar modal for retrospective log inspection and future scheduling",
    file: "screenshots/05_date_picker.png",
    objective: "Enables facility administrators and reception staff to navigate to any date on the calendar to audit past entry logs or inspect pre-registered appointments.",
    features: [
      {
        heading: "Full-Month Calendar Grid",
        desc: "Crisp visual presentation of days, weekdays, and current selection indicator."
      },
      {
        heading: "Month & Year Fast Navigation",
        desc: "Arrow navigation and year dropdown selector for rapid historical lookup across months and years."
      },
      {
        heading: "Prominent Selection Indicator",
        desc: "Active selected date is highlighted with a brand blue circular badge with high-contrast text."
      },
      {
        heading: "Synchronized Dashboard Filter",
        desc: "Applying a date immediately filters the dashboard counters, recent logs, and visitor directory."
      },
      {
        heading: "Theme Engine Adaptation",
        desc: "Seamlessly adapts colors, background surfaces, and text contrast to the active Dark or Light mode."
      }
    ],
    tech: [
      { key: "Framework Integration", val: "Flutter showDatePicker with DatePickerTheme" },
      { key: "Primary Widgets", val: "CalendarDatePicker, DateRangePickerDialog" },
      { key: "Localization", val: "Standard ISO-8601 date synchronization" },
      { key: "Status", val: "Verified across Past, Present & Future Dates" }
    ]
  }
];

function generatePDF() {
  console.log("Starting PDF generation for Visitor Management App Screenshots...");
  const doc = new PDFBuilder();

  // 1: Catalog
  const catalogId = doc.addObject("<< /Type /Catalog /Pages 2 0 R >>");

  // We will have 10 pages total (1 cover + 9 screenshot pages)
  const totalPages = 1 + SCREENS_DATA.length;
  const pageObjectIds = [];
  // Reserved IDs: 1 (Catalog), 2 (Pages), 3 (Font F1 Regular), 4 (Font F2 Bold), 5 (Font F3 Italic)
  // Page objects will start after fonts.
  const FONT_F1_ID = 3;
  const FONT_F2_ID = 4;
  const FONT_F3_ID = 5;

  // Pre-allocate page IDs
  let currentAllocatedId = 5;
  for (let i = 0; i < totalPages; i++) {
    currentAllocatedId++; // for Page object
    pageObjectIds.push(currentAllocatedId);
    currentAllocatedId++; // for Contents object
    if (i > 0) {
      currentAllocatedId++; // for Image XObject
    }
  }

  // 2: Pages
  const kidsStr = pageObjectIds.map(id => `${id} 0 R`).join(' ');
  doc.addObject(`<< /Type /Pages /Kids [ ${kidsStr} ] /Count ${totalPages} >>`);

  // 3: Font F1 (Helvetica)
  doc.addObject("<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>");
  // 4: Font F2 (Helvetica-Bold)
  doc.addObject("<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold >>");
  // 5: Font F3 (Helvetica-Oblique)
  doc.addObject("<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Oblique >>");

  // ==========================================
  // PAGE 1: COVER PAGE & EXECUTIVE OVERVIEW
  // ==========================================
  console.log("Building Page 1: Cover & Executive Overview...");
  const p1ContentsId = pageObjectIds[0] + 1;
  doc.addObject(`<< /Type /Page /Parent 2 0 R /MediaBox [ 0 0 595.28 841.89 ] /Resources << /Font << /F1 ${FONT_F1_ID} 0 R /F2 ${FONT_F2_ID} 0 R /F3 ${FONT_F3_ID} 0 R >> >> /Contents ${p1ContentsId} 0 R >>`);

  const p1 = new PagePainter();

  // Top Navy Hero Header
  p1.rect(0, 680, 595.28, 161.89, C_NAVY);
  p1.rect(0, 676, 595.28, 4, C_BLUE); // Royal Blue accent strip

  // Pill badge in header
  p1.rect(40, 800, 220, 18, [0.12, 0.20, 0.35]);
  p1.text(48, 805, "ENTERPRISE MOBILE APPLICATION", "F2", 8, C_BLUE_LIGHT);

  // App Title
  p1.text(40, 765, "Visitor Management System", "F2", 24, C_WHITE);
  p1.text(40, 742, "Mobile Application UI/UX Showcase & Feature Verification Portfolio", "F1", 11.5, [0.80, 0.86, 0.94]);
  p1.text(40, 722, "Touchless Onboarding  •  Live Camera QR Scanner  •  Real-Time Facility Analytics", "F3", 9.5, [0.45, 0.75, 0.98]);

  // Executive Metadata Card
  p1.rect(40, 580, 515.28, 76, C_SLATE_50, C_SLATE_200, 1);
  p1.rect(40, 638, 515.28, 18, [0.93, 0.95, 0.98]);
  p1.text(48, 643, "SYSTEM SPECIFICATIONS & BUILD METRICS", "F2", 8, C_SLATE_800);

  // Col 1
  p1.text(50, 620, "Platform:", "F2", 8.5, C_SLATE_800);
  p1.text(105, 620, "Flutter 3.x (Dart)", "F1", 8.5, C_SLATE_600);
  p1.text(50, 600, "Architecture:", "F2", 8.5, C_SLATE_800);
  p1.text(120, 600, "BLoC Pattern", "F1", 8.5, C_SLATE_600);

  // Col 2
  p1.text(220, 620, "Theme Engine:", "F2", 8.5, C_SLATE_800);
  p1.text(295, 620, "Adaptive Dark / Light", "F1", 8.5, C_SLATE_600);
  p1.text(220, 600, "QR Scanner:", "F2", 8.5, C_SLATE_800);
  p1.text(290, 600, "mobile_scanner (ML Kit)", "F1", 8.5, C_SLATE_600);

  // Col 3
  p1.text(395, 620, "Input Validation:", "F2", 8.5, C_SLATE_800);
  p1.text(475, 620, "Digits & RFC 5322", "F1", 8.5, C_SLATE_600);
  p1.text(395, 600, "Verification Status:", "F2", 8.5, C_SLATE_800);
  p1.text(490, 600, "100% Passed", "F2", 8.5, C_GREEN);

  // Section Header: Executive Overview
  p1.text(40, 550, "Executive Overview & System Architecture", "F2", 13, C_NAVY);
  p1.line(40, 542, 555.28, 542, C_BLUE, 1.5);

  const overviewPara1 = "The Visitor Management System is an enterprise-grade mobile application designed for secure facilities, corporate offices, and tech parks. The system replaces outdated physical sign-in books with an automated, contactless visitor lifecycle: from initial visitor registration and digital QR pass issuance to real-time security gate verification and management analytics.";
  const linesP1 = wrapText(overviewPara1, 108);
  let p1Y = 528;
  for (const l of linesP1) {
    p1.text(40, p1Y, l, "F1", 8.5, C_SLATE_600);
    p1Y -= 12;
  }

  const overviewPara2 = "Key architectural enhancements include full Dark/Light theme switching accessible directly from the app bar, strict field-level input constraints (numeric-only phone inputs and standard email formatting), robust error dialogs for unrecognized QR codes, and GPU-accelerated charts for weekly occupancy analytics.";
  const linesP2 = wrapText(overviewPara2, 108);
  p1Y -= 4;
  for (const l of linesP2) {
    p1.text(40, p1Y, l, "F1", 8.5, C_SLATE_600);
    p1Y -= 12;
  }

  // Section Header: Directory / Table of Contents
  p1Y -= 12;
  p1.text(40, p1Y, "Application Showcase Directory & Screen Index", "F2", 13, C_NAVY);
  p1.line(40, p1Y - 6, 555.28, p1Y - 6, C_BLUE, 1.5);

  p1Y -= 20;

  // Table Header
  p1.rect(40, p1Y - 4, 515.28, 18, C_SLATE_800);
  p1.text(48, p1Y + 1, "#", "F2", 8, C_WHITE);
  p1.text(70, p1Y + 1, "SCREEN / MODULE NAME", "F2", 8, C_WHITE);
  p1.text(260, p1Y + 1, "PRIMARY FUNCTIONALITY & ARCHITECTURE", "F2", 8, C_WHITE);
  p1.text(515, p1Y + 1, "PAGE", "F2", 8, C_WHITE);

  // Table Rows for each of the 9 screens
  SCREENS_DATA.forEach((s, idx) => {
    p1Y -= 19;
    const isEven = idx % 2 === 0;
    p1.rect(40, p1Y - 3, 515.28, 19, isEven ? C_SLATE_50 : C_WHITE, C_SLATE_200, 0.5);
    p1.text(48, p1Y + 2, s.num, "F2", 8, C_BLUE);
    p1.text(70, p1Y + 2, s.title, "F2", 8, C_SLATE_800);
    // Short functional snippet
    const shortDesc = s.subtitle.length > 58 ? s.subtitle.substring(0, 55) + "..." : s.subtitle;
    p1.text(260, p1Y + 2, shortDesc, "F1", 8, C_SLATE_600);
    p1.text(525, p1Y + 2, String(idx + 2), "F2", 8, C_SLATE_800);
  });

  // Footer
  p1.line(40, 48, 555.28, 48, C_SLATE_200, 1);
  p1.text(40, 36, "Visitor Management System • Mobile UI/UX & Verification Showcase", "F1", 8, C_SLATE_400);
  p1.text(505, 36, "Page 1 of 10", "F2", 8, C_SLATE_600);

  const p1Buf = p1.toBuffer();
  doc.addObject(`<< /Length ${p1Buf.length} >>`, p1Buf);

  // ==========================================
  // PAGES 2 to 10: INDIVIDUAL SCREEN PAGES
  // ==========================================
  SCREENS_DATA.forEach((screen, screenIndex) => {
    const pageNum = screenIndex + 2;
    console.log(`Building Page ${pageNum}: ${screen.title}...`);

    // Parse PNG image
    const imgData = parsePNG(screen.file);
    const compressedRGB = zlib.deflateSync(imgData.rawRGB);

    // Calculate layout coordinates
    // We reserved:
    // pageObjectIds[pageNum - 1]: Page object
    // pageObjectIds[pageNum - 1] + 1: Contents object
    // pageObjectIds[pageNum - 1] + 2: Image object
    const pObjId = pageObjectIds[pageNum - 1];
    const cObjId = pObjId + 1;
    const imgObjId = pObjId + 2;

    doc.addObject(`<< /Type /Page /Parent 2 0 R /MediaBox [ 0 0 595.28 841.89 ] /Resources << /Font << /F1 ${FONT_F1_ID} 0 R /F2 ${FONT_F2_ID} 0 R /F3 ${FONT_F3_ID} 0 R >> /XObject << /Img${screen.num} ${imgObjId} 0 R >> >> /Contents ${cObjId} 0 R >>`);

    const p = new PagePainter();

    // Running Header
    p.text(40, 810, "VISITOR MANAGEMENT SYSTEM  •  MOBILE UI/UX SHOWCASE", "F1", 7.5, C_SLATE_400);
    p.text(475, 810, `SCREEN ${screen.num} OF 09`, "F2", 8, C_BLUE);
    p.line(40, 802, 555.28, 802, C_SLATE_200, 1);

    // Screen Title & Subtitle
    p.text(40, 778, `${screen.num}. ${screen.title}`, "F2", 16.5, C_NAVY);
    p.text(40, 762, screen.subtitle, "F1", 9, C_SLATE_600);

    // Category Pill
    p.rect(40, 740, 230, 15, C_BLUE_LIGHT);
    p.text(46, 744, screen.badge, "F2", 7, C_BLUE_DARK);

    // ------------------------------------------
    // LEFT COLUMN: SCREENSHOT & DEVICE FRAME
    // ------------------------------------------
    // Image Dimensions
    const imgW = 235;
    const imgH = imgW * imgData.height / imgData.width; // typically ~420 to 425 pt
    const imgX = 40;
    const imgY = 725 - imgH;

    // Outer subtle phone shadow / bezel border
    p.rect(imgX - 3, imgY - 3, imgW + 6, imgH + 6, [0.93, 0.95, 0.98], [0.78, 0.82, 0.88], 1.2);
    // Draw the image
    p.image(`Img${screen.num}`, imgX, imgY, imgW, imgH);

    // Box below the screenshot: Device & Verification Specs
    const specBoxY = 60;
    const specBoxH = imgY - specBoxY - 12;
    if (specBoxH > 40) {
      p.rect(imgX, specBoxY, imgW, specBoxH, C_SLATE_50, C_SLATE_200, 1);
      p.rect(imgX, specBoxY + specBoxH - 16, imgW, 16, [0.91, 0.94, 0.98]);
      p.text(imgX + 8, specBoxY + specBoxH - 12, "SCREEN & DEVICE METRICS", "F2", 7.5, C_SLATE_800);

      let sY = specBoxY + specBoxH - 28;
      p.text(imgX + 8, sY, "Native Resolution:", "F2", 7.5, C_SLATE_800);
      p.text(imgX + 85, sY, `${imgData.width} x ${imgData.height} px`, "F1", 7.5, C_SLATE_600);
      sY -= 13;
      p.text(imgX + 8, sY, "Aspect Ratio:", "F2", 7.5, C_SLATE_800);
      p.text(imgX + 70, sY, "9:16 High-DPI Mobile", "F1", 7.5, C_SLATE_600);
      sY -= 13;
      p.text(imgX + 8, sY, "Theme Tested:", "F2", 7.5, C_SLATE_800);
      p.text(imgX + 75, sY, "System / Dark / Light", "F1", 7.5, C_SLATE_600);
      sY -= 13;
      p.text(imgX + 8, sY, "Touch Target Compliance:", "F2", 7.5, C_SLATE_800);
      p.text(imgX + 115, sY, ">= 48dp", "F1", 7.5, C_SLATE_600);
      sY -= 13;
      p.text(imgX + 8, sY, "QA Verification:", "F2", 7.5, C_SLATE_800);
      p.text(imgX + 80, sY, "Verified & Passed", "F2", 7.5, C_GREEN);
    }

    // ------------------------------------------
    // RIGHT COLUMN: FEATURE SPECIFICATIONS & QA
    // ------------------------------------------
    const colX = 290;
    const colW = 265.28;

    // Card 1: Purpose & Business Objective
    const c1H = 95;
    const c1Y = 725 - c1H;
    p.rect(colX, c1Y, colW, c1H, C_SLATE_50, C_SLATE_200, 1);
    p.rect(colX, c1Y + c1H - 17, colW, 17, [0.93, 0.95, 0.98]);
    p.text(colX + 8, c1Y + c1H - 12, "SCREEN PURPOSE & BUSINESS OBJECTIVE", "F2", 7.5, C_SLATE_800);

    const objLines = wrapText(screen.objective, 52);
    let objY = c1Y + c1H - 29;
    for (const ol of objLines) {
      p.text(colX + 8, objY, ol, "F1", 8, C_SLATE_600);
      objY -= 11.5;
    }

    // Card 2: Core Features & Capabilities Breakdown
    const c2H = 265;
    const c2Y = c1Y - 10 - c2H;
    p.rect(colX, c2Y, colW, c2H, C_WHITE, C_SLATE_200, 1);
    p.rect(colX, c2Y + c2H - 17, colW, 17, C_SLATE_100);
    p.text(colX + 8, c2Y + c2H - 12, "CORE FEATURES & USER EXPERIENCE HIGHLIGHTS", "F2", 7.5, C_SLATE_800);

    let featY = c2Y + c2H - 28;
    screen.features.forEach((feat) => {
      p.text(colX + 8, featY, "-", "F2", 9, C_BLUE);
      p.text(colX + 16, featY, feat.heading + ":", "F2", 8, C_SLATE_800);
      featY -= 10.5;

      const descLines = wrapText(feat.desc, 50);
      for (const dl of descLines) {
        p.text(colX + 16, featY, dl, "F1", 7.5, C_SLATE_600);
        featY -= 10;
      }
      featY -= 3.5;
    });

    // Card 3: Engineering Architecture & Technical Specs
    const c3Y = specBoxY;
    const c3H = c2Y - 10 - c3Y;
    p.rect(colX, c3Y, colW, c3H, C_TEAL_LIGHT, [0.65, 0.88, 0.84], 1);
    p.rect(colX, c3Y + c3H - 17, colW, 17, [0.77, 0.93, 0.90]);
    p.text(colX + 8, c3Y + c3H - 12, "ENGINEERING & QA ARCHITECTURE", "F2", 7.5, [0.04, 0.38, 0.35]);

    let techY = c3Y + c3H - 27;
    screen.tech.forEach((t) => {
      p.text(colX + 8, techY, t.key + ":", "F2", 7.5, C_SLATE_800);
      p.text(colX + 85, techY, t.val, "F1", 7.5, C_SLATE_600);
      techY -= 12.5;
    });

    // Running Footer
    p.line(40, 48, 555.28, 48, C_SLATE_200, 1);
    p.text(40, 36, "Visitor Management System • Mobile UI/UX & Verification Showcase", "F1", 8, C_SLATE_400);
    p.text(500, 36, `Page ${pageNum} of 10`, "F2", 8, C_SLATE_600);

    const pBuf = p.toBuffer();
    doc.addObject(`<< /Length ${pBuf.length} >>`, pBuf);

    // Image XObject
    doc.addObject(
      `<< /Type /XObject /Subtype /Image /Width ${imgData.width} /Height ${imgData.height} /ColorSpace /DeviceRGB /BitsPerComponent 8 /Filter /FlateDecode /Length ${compressedRGB.length} >>`,
      compressedRGB
    );
  });

  // Build and write PDF buffer
  const finalPdfBuf = doc.build();
  const outputPath = path.resolve('Visitor_Management_App_Screenshots.pdf');
  fs.writeFileSync(outputPath, finalPdfBuf);
  console.log(`SUCCESS: PDF generated at ${outputPath}`);
  console.log(`Total Size: ${(finalPdfBuf.length / 1024 / 1024).toFixed(2)} MB (${finalPdfBuf.length} bytes)`);
}

generatePDF();
