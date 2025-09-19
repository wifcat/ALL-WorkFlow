let editedRows = [];
    let editedCells = {};
    let headers = [], fullDataRows = [], rawHeaderLines = [], fileLoaded = false;
    let defaultDataRows = [];

    //event listener
  document.getElementById('addStatBtn').addEventListener('click', () => {
  if (!fileLoaded) {
    alert('Load a pedstats.dat file first.');
    return;
  }

  const newName = prompt("Enter new stat name:");
  if (!newName || !newName.trim()) {
    return; 
  }

  const defaultRow = defaultDataRows[1] ? [...defaultDataRows[1]] : Array(headers.length).fill("");
  defaultRow[0] = newName.trim(); // set stat name

  fullDataRows.push(defaultRow);

  const newIndex = fullDataRows.length - 1;
  renderStatLinks();

  const existingModal = bootstrap.Modal.getInstance(document.getElementById('statModal'));
  if (existingModal) existingModal.hide();

  renderAccordion(newIndex);
});



    function markEdited(rowIndex, colIndex) {
      // markdown stat(s)
      editedRows[rowIndex] = true;

      // markdown cell(s)
      if (!editedCells[rowIndex]) editedCells[rowIndex] = [];
      editedCells[rowIndex][colIndex] = true;

      // highlight stat link
      const link = document.querySelector(`.stat-link[data-index="${rowIndex}"]`);
      if (link) link.classList.add('edited-stat');

      // highlight accordion header 
      const accHeader = document.querySelector(`#heading-modal-stat-${rowIndex}-col-${colIndex} .accordion-button`);
      if (accHeader) accHeader.classList.add('edited-stat');

      // highlight 
      // const accInput = document.querySelector(`#body-modal-stat-${rowIndex}-col-${colIndex} input`);
      // if (accInput) accInput.classList.add('edited-input');
    }
    // the default pedstats..
    fetch('pedstats2.dat')
      .then(res => res.text())
      .then(text => {
        const lines = text.split('\n').map(l => l.replace(/\r$/, ''));
        const dataStartIndex = lines.findIndex(l => !l.startsWith('#'));
        const rawData = lines.slice(dataStartIndex).filter(l => l.trim());
        defaultDataRows = rawData.map(row => row.split('\t'));
      })
      .catch(() => console.warn('pedstats2.dat not found'));

    document.getElementById('fileInput').addEventListener('change', e => {
      const file = e.target.files[0];
      if (!file) return;
      const reader = new FileReader();
      reader.onload = e => parseData(e.target.result);
      reader.readAsText(file);
    });

    document.getElementById('openFromServerBtn').addEventListener('click', () => {
    fetch('pedstats.dat')
      .then(res => {
        if (!res.ok) throw new Error('File not found');
        return res.text();
      })
      .then(parseData)
      .catch(() => alert('pedstats.dat not found in the same directory.'));
  });

    function parseData(text) {
      const lines = text.split('\n').map(l => l.replace(/\r$/, ''));
      const dataStartIndex = lines.findIndex(l => !l.startsWith('#'));
      rawHeaderLines = lines.slice(0, dataStartIndex);
      const rawData = lines.slice(dataStartIndex).filter(l => l.trim());
      headers = rawHeaderLines.map(line => {
  // for any other # without : do
      if (line.startsWith('#') && !line.includes(':')) {
        // ex: # BM > # BM:
        const parts = line.split(/\s+/).filter(Boolean);
        if (parts.length > 2) {
          const code = parts[1];
          const desc = parts.slice(2).join(' ');
          line = `#\t${code}:\t${desc}`;
        }
      }
      const match = line.match(/^#\s*(\w+):\s*(.+)$/);
      return match ? `${match[1]}: ${match[2]}` : null;
    }).filter(Boolean);
      fullDataRows = rawData.map(row => row.split('\t').slice(0, headers.length));
      // irl edited history
      editedRows = [];
      editedCells = {};
      fileLoaded = true;
      renderStatLinks();
      originalDataRows = JSON.parse(JSON.stringify(fullDataRows));
      if (columnTypes["A"] === "O") {
        columnOptions["A"] = [...new Set(fullDataRows.map(row => row[0]))];
      }
    }

    function renderStatLinks() {
      const container = document.getElementById('statList');
      container.innerHTML = '';
      document.getElementById('statAccordion').innerHTML = '';
      fullDataRows.forEach((row, index) => {
        const statName = row[0];
        const link = document.createElement('a');
        link.href = `#`;
        link.className = 'stat-link';
        link.textContent = statName;
        link.dataset.index = index;
        link.className = 'stat-link' + (editedRows[index] ? ' edited-stat' : '');
        link.addEventListener('click', e => {
          e.preventDefault();
          renderAccordion(parseInt(link.dataset.index));
        });
        container.appendChild(link);
      });

    }

    function renderInputField(rowIndex, colIndex) {
      const colLetter = headers[colIndex].split(':')[0].trim(); 
      const currentValue = fullDataRows[rowIndex][colIndex] || "";
      const type = columnTypes[colLetter];

      if (type === "O" && columnOptions[colLetter]) {
  return `
    <div class="cell-radio-group">
      ${columnOptions[colLetter].map(opt => `
        <label class="form-check">
          <input type="radio" 
                 name="col-${rowIndex}-${colIndex}" 
                 value="${opt}" 
                 class="form-check-input"
                 ${opt === currentValue ? "checked" : ""}
                 onchange="fullDataRows[${rowIndex}][${colIndex}] = this.value; markEdited(${rowIndex}, ${colIndex});">
          <span class="form-check-label">${opt}</span>
        </label>
      `).join("")}
    </div>
  `;
}

      if (type === "I") {
        return `
          <input min="0" max="1000" placeholder="Type a Number here" type="number" class="form-control cell-input"
                value="${currentValue}"
                onchange="fullDataRows[${rowIndex}][${colIndex}] = this.value; markEdited(${rowIndex}, ${colIndex});" />
        `;
      }

      return `
        <input placeholder="Type here" type="text" class="form-control cell-input"
              value="${currentValue}"
              onchange="fullDataRows[${rowIndex}][${colIndex}] = this.value; markEdited(${rowIndex}, ${colIndex});" />
      `;
    }

    function renderAccordion(index) {
      const modalContainer = document.getElementById('statModalContent');
      const statName = fullDataRows[index][0];
      const subAccordions = headers.map((header, i) => {
      const subId = `modal-stat-${index}-col-${i}`;
      const columnKey = header.split(':')[0].trim();
        return `
      <div class="accordion-item">
        <h2 class="accordion-header" id="heading-${subId}">
          <button class="accordion-button collapsed ${editedCells[index]?.[i] ? 'edited-stat' : ''}" 
                  type="button" 
                  data-bs-toggle="collapse" 
                  data-bs-target="#collapse-${subId}" 
                  aria-expanded="false">
            ${header}
          </button>

        </h2>
        <div id="collapse-${subId}" class="accordion-collapse collapse" data-bs-parent="#modalAccordion">
          <div class="accordion-body" id="body-${subId}">
            ${renderInputField(index, i)}
            <input class="form-control badge-input mt-2"
       value="DEFAULT: ${defaultDataRows[index]?.[i] || ''}"
       readonly />
            <div class="mt-2 text-muted small">
              ${columnDescriptions[columnKey] || ''}
            </div>

          </div>
        </div>
      </div>
    `;
  }).join('');
  setTimeout(() => {
  document.querySelectorAll(`#modalAccordion .accordion-button`).forEach((btn) => {
    btn.addEventListener('click', () => {
      const targetId = btn.getAttribute('data-bs-target').replace('#collapse-', '');
      const parts = targetId.split('-'); // "stat-3-col-0"
      const index = parseInt(parts[1]);
      const colIndex = parseInt(parts[3]);
      const inputHtml = `
      <input class="form-control cell-input ${editedCells[index]?.[colIndex] ? 'edited-input' : ''}"
            value="${fullDataRows[index][colIndex] || ''}"
            onchange="fullDataRows[${index}][${colIndex}] = this.value; markEdited(${index}, ${colIndex});" />
    `;

      const container = document.getElementById(`body-${targetId}`);
      if (container && !container.innerHTML.trim()) {
        container.innerHTML = inputHtml;
      }
    });
  });
}, 100); // delay 


  modalContainer.innerHTML = `
    <div class="modal-header">
      <h5 class="modal-title">${statName}</h5>
      <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
    </div>
    <div class="modal-body">
      <div class="accordion" id="modalAccordion">
        ${subAccordions}
      </div>
    </div>
  `;

  const modal = new bootstrap.Modal(document.getElementById('statModal'));
  modal.show();
}


    document.getElementById('searchInput').addEventListener('input', (e) => {
      const query = e.target.value.trim().toLowerCase();
      Array.from(document.querySelectorAll('.stat-link')).forEach(link => {
        const name = link.textContent.toLowerCase();
        link.style.display = name.includes(query) ? '' : 'none';
      });
    });

    document.getElementById('downloadBtn').addEventListener('click', () => {
      if (!fileLoaded) return alert('Please load a pedstats.dat file first.');
      const output = rawHeaderLines.join('\n') + '\n' + fullDataRows.map(r => r.join('\t')).join('\n');
      saveDraft(output);
      const blob = new Blob([output], { type: 'text/plain' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = 'pedstats.dat';
      a.click();
    });

    function saveDraft(content) {
      let drafts = JSON.parse(localStorage.getItem('pedstatsDrafts') || '[]');
      const now = Date.now();
      drafts = drafts.filter(d => now - d.timestamp < 12 * 60 * 60 * 1000);
      if (drafts.length >= 5) drafts.shift();
      drafts.push({ content, timestamp: now });
      localStorage.setItem('pedstatsDrafts', JSON.stringify(drafts));
    }

    function showDrafts() {
      const draftList = document.getElementById('draftList');
      const drafts = JSON.parse(localStorage.getItem('pedstatsDrafts') || '[]')
        .filter(d => Date.now() - d.timestamp < 12 * 60 * 60 * 1000);
      if (!drafts.length) {
        draftList.innerHTML = '<p class="text-muted">No drafts available.</p>';
        return;
      }
      draftList.innerHTML = drafts.map((d, i) => `
        <div class="mb-2">
          <button class="btn btn-sm btn-outline-primary w-100 mb-1" onclick="loadDraft(${i})">
            Load Draft #${i + 1} (${new Date(d.timestamp).toLocaleTimeString()})
          </button>
        </div>
      `).join('');
    }

    function loadDraft(index) {
      const drafts = JSON.parse(localStorage.getItem('pedstatsDrafts') || '[]');
      const draft = drafts[index];
      if (draft) parseData(draft.content);
      const modal = bootstrap.Modal.getInstance(document.getElementById('draftModal'));
      modal.hide();
    }

    document.getElementById('draftModal').addEventListener('show.bs.modal', showDrafts);

const columnDescriptions = {
  "A": "(Do not change) Example ped stat name. Example: STAT_PLAYER",
  "B": "Ped ID/name reference. Example: FRAFFYCAN (Beam Cola)",
  "C": "Drop rate for items (higher = more drops). Example: 100",
  "D": "(Not for Player) View angle in degrees. Ped can see half each side (value ÷ 2). Example: Damon = 360 (sees everything around).",
  "E": "(Not for Player) View distance — how far a ped detects others. Example: 35",
  "F": "Max health of ped/player. (Player must be KO’d first for it to apply.) Example: 500",
  "G": "Health regeneration rate. Example: 600",
  "H": "Fear of bullies (not for Player). Example: 60",
  "I": "(Not for Player) Frequency of reporting suspicious activity to prefects. Example: 100",
  "J": "(Not for Player) Attack frequency in fights. Higher = more aggressive. Example: 1000 = constant attacks, 50 = rare attacks",
  "K": "(Not for Player) Attack frequency while on a bike. Example: 130",
  "L": "(Possibly works for Player) Projectile throw accuracy at Player. Example: 100",
  "M": "Projectile attack frequency. Example: 100",
  "N": "(Lua mod) Frequency of blocking punches. Example: 100",
  "O": "General block frequency (same as N). Example: 100",
  "P": "(Likely not for Player) Aggressiveness to initiate/continue fights. Example: 75",
  "Q": "Aggressiveness increase after being insulted. Example: 60",
  "R": "Stamina for sprinting (higher = longer, very high = infinite). Example: 100",
  "S": "Combat class type. Example: STRIKER, GRAPPLER, RANGED",
  "T": "Preference for ranged vs melee combat. Higher = ranged, lower = fists. Example: 50",
  "U": "Preferred orientation (bitfield): 1 = front, 2 = side, 4 = back. Combos allowed (3 = front+side, 7 = all).",
  "V": "Movement speed (higher = faster). Example: 150",
  "W": "Zone weighting. Higher = ped appears more often in that zone (school, dorm, town, etc.).",
  "X": "Special meter (like Jimmy’s blue bar). Only certain NPCs/bosses use this.",
  "Y": "Special points value (starting/max energy). Used for special moves. Example: Russell starts full.",
  "Z": "Cycling speed (free roam). Example: 20",
  "AA": "Bike riding speed. Example: 100",
  "AB": "Bike wait speed (cruising pace when idling/following). Example: 20",
  "AC": "Bike flee distance. How far a ped rides to escape. Example: 50 = short, 200 = far.",
  "AD": "Chase speed when pursuing Player on bike. Example: 10",
  "AE": "Possibly reaction distance (unconfirmed). Example: 10",
  "AF": "Frequency of using projectiles while biking. Example: 70",
  "AG": "Damage dealt to Player/peds. Example: 70 or 100",
  "AH": "Possibly swimming ability (unconfirmed).",
  "AI": "Resistance to knockdowns or bike falls. Example: 100",
  "AJ": "Flee chance if wanted/criminal meter is high.",
  "AK": "Flee speed on bike (works with AJ).",
  "AL": "Follow speed on bike (while trailing Player/peds). Example: 90",
  "AM": "Catch-up speed with Player/peds. Example: 90",
  "AN": "Recovery speed from knee drop. Example: 100",
  "AO": "Break-free speed from grabs (anti-grapple mods). Example: 100",
  "AP": "Night spawn weapon. Example: W_Flashlight",
  "AQ": "Bike type ped can ride. Example: banbike, crapbmx, oldbike",
  "AR": "Bike type ped can ride (same as AQ).",
  "AS": "Bike type ped can ride (same as AQ).",
  "AT": "Weapon spawn chance (percentage). Example: 50",
  "AU": "Default spawn weapon (use 'Unarmed' for none). Example: eggproj, slingshot, stinkbomb",
  "AV": "Ammo count for default weapon. Example: 30",
  "AW": "Weapon slot 1 weight (higher = chosen more often). Example: Slingshot 10 vs Firecracker 5.",
  "AX": "Weapon slot 1 availability. 'init' = from start, or mission name to unlock later. Example: RussellInTheHole",
  "AY": "Weapon slot 2 ID (melee or projectile).",
  "AZ": "Weapon slot 2 ammo count (ignored for melee).",
  "BA": "Weapon slot 2 weight (higher = chosen more often).",
  "BB": "Weapon slot 2 availability (init or mission).",
  "BC": "Weapon slot 3 ID.",
  "BD": "Weapon slot 3 ammo count.",
  "BE": "Weapon slot 3 weight.",
  "BF": "Weapon slot 3 availability.",
  "BG": "Weapon slot 4 ID.",
  "BH": "Weapon slot 4 ammo count.",
  "BI": "Weapon slot 4 weight.",
  "BJ": "Weapon slot 4 availability.",
  "BK": "Recovery speed for rejoining fights. Example: 100",
  "BL": "Knockdown flag. 1 = can be knocked down, 0 = immune. Example: 0",
  "BM": "Health threshold for humiliation. Example: 500"
};
const columnTypes = { // type.data
      "A": "S",  // string | integer | option
      "B": "S",
      "C": "I", // 1-100
      "D": "I", // 2-~
      "E": "I",
      "F": "I",
      "G": "I",
      "H": "I",
      "I": "I",
      "J": "I",
      "K": "I",
      "L": "I",
      "M": "I",
      "N": "I",
      "O": "I",
      "P": "I",
      "Q": "I",
      "R": "I",
      "S": "O",
      "T": "I",
      "U": "I",
      "V": "I",
      "W": "I",
      "X": "I",
      "Y": "I",
      "Z": "I",
      "AA": "I",
      "AB": "I",
      "AC": "I",
      "AD": "I",
      "AE": "I",
      "AF": "I",
      "AG": "I",
      "AH": "I",
      "AI": "I",
      "AJ": "I",
      "AK": "I",
      "AL": "I",
      "AM": "I",
      "AN": "I",
      "AO": "I",
      "AP": "S",
      "AQ": "O",
      "AR": "O",
      "AS": "O",
      "AT": "I",
      "AU": "S",
      "AV": "I",
      "AW": "I",
      "AX": "S",
      "AY": "S",
      "AZ": "I",
      "BA": "I",
      "BB": "S",
      "BC": "S",
      "BD": "I",
      "BE": "I",
      "BF": "S",
      "BG": "S",
      "BH": "I",
      "BI": "I",
      "BJ": "S",
      "BK": "I",
      "BL": "O",
      "BM": "I"
    };


const columnOptions = {
      "S": ["Generic", "Striker", "Grappler", "Ranged", "Melee"],
      "BL": ["0", "1"],
      "AQ": ["None", "aquabike", "racer", "mtnbike", "banbike", "bike", "	Scooter", "crapbmx", "retro", "	bmxrace"],
      "AR": ["None", "aquabike", "racer", "mtnbike", "banbike", "bike", "	Scooter", "crapbmx", "retro", "	bmxrace"],
      "AS": ["None", "aquabike", "racer", "mtnbike", "banbike", "bike", "	Scooter", "crapbmx", "retro", "	bmxrace"]
    };
