'use client';

import { useState } from 'react';

type Screen = 'home' | 'habits' | 'dashboard' | 'media' | 'backup' | 'settings';

// Habit Types
interface Habit {
  id: string;
  name: string;
  icon: string;
  color: string;
  target: number;
  current: number;
  streak: number;
  category: string;
}

// Mood Entry Types
interface MoodEntry {
  date: string;
  mood: number;
  emoji: string;
}

// Insight Types
interface Insight {
  title: string;
  description: string;
  type: 'positive' | 'negative' | 'trend' | 'suggestion';
}

export default function LifeSyncPreview() {
  const [activeScreen, setActiveScreen] = useState<Screen>('habits');
  const [selectedMood, setSelectedMoodood] = useState<number | null>(null);
  
  // Habits State
  const [habits] = useState<Habit[]>([
    { id: '1', name: 'Wasser trinken', icon: '💧', color: '#3b82f6', target: 8, current: 5, streak: 14, category: 'Gesundheit' },
    { id: '2', name: 'Meditation', icon: '🧘', color: '#a855f7', target: 1, current: 1, streak: 21, category: 'Achtsamkeit' },
    { id: '3', name: 'Sport', icon: '🏃', color: '#22c55e', target: 1, current: 0, streak: 5, category: 'Fitness' },
    { id: '4', name: 'Lesen', icon: '📚', color: '#f97316', target: 30, current: 15, streak: 7, category: 'Lernen' },
    { id: '5', name: 'Schlaf 7h+', icon: '😴', color: '#6366f1', target: 1, current: 1, streak: 3, category: 'Gesundheit' },
  ]);

  // Mood Heatmap Data (last 30 days)
  const [moodHeatmap] = useState<MoodEntry[]>(() => {
    const entries: MoodEntry[] = [];
    const moods = [5, 4, 3, 4, 5, 4, 3, 2, 3, 4, 5, 4, 4, 5, 4, 3, 4, 5, 5, 4, 3, 4, 5, 4, 3, 4, 5, 4, 5, 4];
    const emojis = ['😢', '😔', '😐', '😊', '😃'];
    for (let i = 0; i < 30; i++) {
      entries.push({
        date: new Date(Date.now() - (29 - i) * 24 * 60 * 60 * 1000).toLocaleDateString('de-DE'),
        mood: moods[i],
        emoji: emojis[moods[i] - 1]
      });
    }
    return entries;
  });

  // Insights
  const [insights] = useState<Insight[]>([
    { title: 'Meditation macht dich glücklicher! 😊', description: 'An Tagen mit Meditation ist deine Stimmung 0.8 Punkte höher.', type: 'positive' },
    { title: '21 Tage in Folge! 🔥', description: 'Du meditierst seit 21 Tagen. Großartige Konsistenz!', type: 'positive' },
    { title: 'Aufwärts-Trend! 📈', description: 'Deine Stimmung hat sich in der letzten Woche verbessert.', type: 'trend' },
    { title: 'Hoher Stress-Level erkannt 😰', description: 'Versuche, mehr Entspannung in deinen Alltag einzubauen.', type: 'suggestion' },
  ]);

  const styles = {
    container: { minHeight: '100vh', background: 'linear-gradient(135deg, #1e293b 0%, #0f172a 100%)', display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '16px', fontFamily: 'system-ui, -apple-system, sans-serif' } as const,
    phoneFrame: { width: '375px', height: '812px', background: '#000', borderRadius: '50px', padding: '12px', boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.5)', position: 'relative' } as const,
    screen: { width: '100%', height: '100%', background: '#f8fafc', borderRadius: '40px', overflow: 'hidden', position: 'relative' } as const,
    statusBar: { height: '48px', padding: '0 24px', display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between', color: '#000', fontSize: '12px', fontWeight: 600, paddingBottom: '4px' } as const,
    bottomNav: { position: 'absolute', bottom: 0, left: 0, right: 0, background: 'rgba(255,255,255,0.95)', backdropFilter: 'blur(20px)', borderTop: '1px solid #e2e8f0', paddingBottom: '24px', paddingTop: '8px', paddingInline: '8px' } as const,
    card: { background: 'white', borderRadius: '16px', padding: '16px', boxShadow: '0 1px 3px rgba(0,0,0,0.1)', border: '1px solid #f1f5f9' } as const,
    button: { background: '#4f46e5', color: 'white', border: 'none', padding: '14px 24px', borderRadius: '12px', fontSize: '14px', fontWeight: 500, cursor: 'pointer', width: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px' } as const,
  };

  const BottomNav = () => (
    <div style={styles.bottomNav}>
      <div style={{ display: 'flex', justifyContent: 'space-around', alignItems: 'center' }}>
        {[
          { id: 'home', icon: '🏠', label: 'Journal' },
          { id: 'habits', icon: '🎯', label: 'Habits' },
          { id: 'dashboard', icon: '📊', label: 'Dashboard' },
          { id: 'settings', icon: '⚙️', label: 'Mehr' },
        ].map((item) => (
          <button
            key={item.id}
            onClick={() => setActiveScreen(item.id as Screen)}
            style={{
              display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '2px',
              padding: '8px', borderRadius: '12px', border: 'none', background: activeScreen === item.id ? '#eef2ff' : 'transparent',
              cursor: 'pointer', transition: 'all 0.2s'
            }}
          >
            <span style={{ fontSize: '20px' }}>{item.icon}</span>
            <span style={{ fontSize: '10px', color: activeScreen === item.id ? '#4f46e5' : '#64748b', fontWeight: activeScreen === item.id ? 600 : 400 }}>
              {item.label}
            </span>
          </button>
        ))}
      </div>
    </div>
  );

  // Habits Screen
  const HabitsScreen = () => {
    const completedCount = habits.filter(h => h.current >= h.target).length;
    const progress = Math.round((completedCount / habits.length) * 100);

    return (
      <div style={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
        <div style={styles.statusBar}>
          <span>9:41</span>
          <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
            <span>📶</span>
            <span>🔋 100%</span>
          </div>
        </div>
        
        <div style={{ flex: 1, overflow: 'auto', padding: '16px', paddingBottom: '100px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
            <h1 style={{ fontSize: '24px', fontWeight: 'bold', color: '#0f172a' }}>Habit Tracker</h1>
            <button style={{ background: '#6366f1', border: 'none', borderRadius: '10px', padding: '8px 12px', color: 'white', fontSize: '12px', fontWeight: 500, cursor: 'pointer' }}>
              + Neu
            </button>
          </div>
          
          {/* Date Navigation */}
          <div style={{ ...styles.card, marginBottom: '16px', textAlign: 'center' }}>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '16px' }}>
              <button style={{ border: 'none', background: 'none', cursor: 'pointer', fontSize: '18px' }}>◀</button>
              <div>
                <div style={{ fontWeight: 600 }}>Heute</div>
                <div style={{ fontSize: '12px', color: '#64748b' }}>{completedCount}/{habits.length} erledigt</div>
              </div>
              <button style={{ border: 'none', background: 'none', cursor: 'pointer', fontSize: '18px' }}>▶</button>
            </div>
          </div>

          {/* Progress Card */}
          <div style={{ ...styles.card, marginBottom: '16px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
              <span style={{ fontWeight: 600 }}>Tagesfortschritt</span>
              <span style={{ fontSize: '24px', fontWeight: 'bold', color: '#6366f1' }}>{progress}%</span>
            </div>
            <div style={{ height: '12px', background: '#e2e8f0', borderRadius: '6px', overflow: 'hidden' }}>
              <div style={{ height: '100%', background: 'linear-gradient(90deg, #6366f1, #a855f7)', width: `${progress}%`, borderRadius: '6px' }} />
            </div>
          </div>

          {/* Habits List */}
          <div style={{ fontSize: '12px', fontWeight: 600, color: '#64748b', marginBottom: '8px' }}>GESUNDHEIT</div>
          {habits.filter(h => h.category === 'Gesundheit').map((habit) => (
            <div key={habit.id} style={{ ...styles.card, marginBottom: '8px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                <div style={{ 
                  width: '48px', height: '48px', borderRadius: '50%', 
                  background: habit.current >= habit.target ? habit.color : 'transparent',
                  border: `2px solid ${habit.color}`,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  fontSize: '20px'
                }}>
                  {habit.current >= habit.target ? '✓' : habit.icon}
                </div>
                <div style={{ flex: 1 }}>
                  <div style={{ fontWeight: 600, textDecoration: habit.current >= habit.target ? 'line-through' : 'none', color: habit.current >= habit.target ? '#94a3b8' : '#0f172a' }}>
                    {habit.name}
                  </div>
                  {habit.target > 1 && (
                    <>
                      <div style={{ fontSize: '12px', color: '#64748b', marginTop: '2px' }}>{habit.current}/{habit.target}</div>
                      <div style={{ height: '4px', background: '#e2e8f0', borderRadius: '2px', marginTop: '4px', overflow: 'hidden' }}>
                        <div style={{ height: '100%', background: habit.color, width: `${(habit.current / habit.target) * 100}%` }} />
                      </div>
                    </>
                  )}
                </div>
                {habit.streak >= 3 && (
                  <div style={{ background: '#fff7ed', padding: '4px 8px', borderRadius: '12px', display: 'flex', alignItems: 'center', gap: '4px' }}>
                    <span style={{ fontSize: '12px' }}>🔥</span>
                    <span style={{ fontSize: '12px', fontWeight: 600, color: '#f97316' }}>{habit.streak}</span>
                  </div>
                )}
              </div>
            </div>
          ))}

          <div style={{ fontSize: '12px', fontWeight: 600, color: '#64748b', marginTop: '16px', marginBottom: '8px' }}>ACHTSAMKEIT</div>
          {habits.filter(h => h.category === 'Achtsamkeit').map((habit) => (
            <div key={habit.id} style={{ ...styles.card, marginBottom: '8px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                <div style={{ 
                  width: '48px', height: '48px', borderRadius: '50%', 
                  background: habit.current >= habit.target ? habit.color : 'transparent',
                  border: `2px solid ${habit.color}`,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  color: habit.current >= habit.target ? 'white' : habit.color,
                  fontSize: '20px'
                }}>
                  {habit.current >= habit.target ? '✓' : habit.icon}
                </div>
                <div style={{ flex: 1 }}>
                  <div style={{ fontWeight: 600 }}>{habit.name}</div>
                </div>
                <div style={{ background: '#fff7ed', padding: '4px 8px', borderRadius: '12px', display: 'flex', alignItems: 'center', gap: '4px' }}>
                  <span style={{ fontSize: '12px' }}>🔥</span>
                  <span style={{ fontSize: '12px', fontWeight: 600, color: '#f97316' }}>{habit.streak}</span>
                </div>
              </div>
            </div>
          ))}
        </div>
        
        <BottomNav />
      </div>
    );
  };

  // Dashboard Screen
  const DashboardScreen = () => (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
      <div style={styles.statusBar}>
        <span>9:41</span>
        <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
          <span>📶</span>
          <span>🔋 100%</span>
        </div>
      </div>
      
      <div style={{ flex: 1, overflow: 'auto', padding: '16px', paddingBottom: '100px' }}>
        <h1 style={{ fontSize: '24px', fontWeight: 'bold', color: '#0f172a', marginBottom: '16px' }}>Dashboard</h1>
        
        {/* Quick Mood */}
        <div style={{ ...styles.card, marginBottom: '16px' }}>
          <div style={{ fontWeight: 600, marginBottom: '12px' }}>Wie fühlst du dich heute?</div>
          <div style={{ display: 'flex', justifyContent: 'space-around' }}>
            {['😢', '😔', '😐', '😊', '😃'].map((emoji, i) => (
              <button
                key={i}
                onClick={() => setSelectedMoodood(i + 1)}
                style={{
                  width: '48px', height: '48px', borderRadius: '50%', border: selectedMood === i + 1 ? '2px solid #6366f1' : '2px solid #e2e8f0',
                  background: selectedMood === i + 1 ? '#eef2ff' : 'transparent', cursor: 'pointer', fontSize: '24px'
                }}
              >
                {emoji}
              </button>
            ))}
          </div>
        </div>

        {/* Mood Heatmap */}
        <div style={{ ...styles.card, marginBottom: '16px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
            <span style={{ fontWeight: 600 }}>Stimmungs-Heatmap</span>
            <span style={{ fontSize: '12px', color: '#64748b' }}>Letzte 30 Tage</span>
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7, 1fr)', gap: '3px' }}>
            {moodHeatmap.map((entry, i) => {
              const intensity = entry.mood / 5;
              return (
                <div
                  key={i}
                  style={{
                    aspectRatio: '1', borderRadius: '3px',
                    background: `rgba(34, 197, 94, ${0.1 + intensity * 0.8})`,
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                    fontSize: '8px'
                  }}
                  title={`${entry.date}: ${entry.emoji}`}
                />
              );
            })}
          </div>
        </div>

        {/* Stats */}
        <div style={{ ...styles.card, marginBottom: '16px' }}>
          <div style={{ fontWeight: 600, marginBottom: '12px' }}>Statistiken (30 Tage)</div>
          
          <div style={{ marginBottom: '12px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '4px' }}>
              <span style={{ fontSize: '12px' }}>Ø Stimmung</span>
              <span style={{ fontSize: '12px', fontWeight: 600, color: '#22c55e' }}>4.1</span>
            </div>
            <div style={{ height: '6px', background: '#e2e8f0', borderRadius: '3px' }}>
              <div style={{ height: '100%', background: '#22c55e', width: '82%', borderRadius: '3px' }} />
            </div>
          </div>

          <div style={{ marginBottom: '12px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '4px' }}>
              <span style={{ fontSize: '12px' }}>Ø Energie</span>
              <span style={{ fontSize: '12px', fontWeight: 600, color: '#3b82f6' }}>3.7</span>
            </div>
            <div style={{ height: '6px', background: '#e2e8f0', borderRadius: '3px' }}>
              <div style={{ height: '100%', background: '#3b82f6', width: '74%', borderRadius: '3px' }} />
            </div>
          </div>

          <div>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '4px' }}>
              <span style={{ fontSize: '12px' }}>Ø Stress</span>
              <span style={{ fontSize: '12px', fontWeight: 600, color: '#ef4444' }}>2.8</span>
            </div>
            <div style={{ height: '6px', background: '#e2e8f0', borderRadius: '3px' }}>
              <div style={{ height: '100%', background: '#ef4444', width: '56%', borderRadius: '3px' }} />
            </div>
          </div>
        </div>

        {/* Insights */}
        <div style={{ ...styles.card, marginBottom: '16px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '12px' }}>
            <span style={{ fontSize: '18px' }}>💡</span>
            <span style={{ fontWeight: 600 }}>Insights</span>
          </div>
          {insights.map((insight, i) => (
            <div key={i} style={{ 
              padding: '12px', borderRadius: '12px', marginBottom: '8px',
              background: insight.type === 'positive' ? '#f0fdf4' : insight.type === 'trend' ? '#eff6ff' : '#fff7ed',
              borderLeft: `3px solid ${insight.type === 'positive' ? '#22c55e' : insight.type === 'trend' ? '#3b82f6' : '#f97316'}`
            }}>
              <div style={{ fontWeight: 600, fontSize: '13px', marginBottom: '4px' }}>{insight.title}</div>
              <div style={{ fontSize: '11px', color: '#64748b' }}>{insight.description}</div>
            </div>
          ))}
        </div>

        {/* Weekly Overview */}
        <div style={styles.card}>
          <div style={{ fontWeight: 600, marginBottom: '12px' }}>Diese Woche</div>
          <div style={{ display: 'flex', justifyContent: 'space-between' }}>
            {['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'].map((day, i) => (
              <div key={day} style={{ textAlign: 'center' }}>
                <div style={{ fontSize: '11px', color: '#64748b', marginBottom: '4px' }}>{day}</div>
                <div style={{ 
                  width: '36px', height: '36px', borderRadius: '50%', 
                  background: i < 5 ? 'rgba(34, 197, 94, 0.2)' : '#f1f5f9',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  border: i === 4 ? '2px solid #6366f1' : 'none'
                }}>
                  {i < 5 ? moodHeatmap[i].emoji : '?'}
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
      
      <BottomNav />
    </div>
  );

  // Backup Screen
  const BackupScreen = () => (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
      <div style={styles.statusBar}>
        <span>9:41</span>
        <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
          <span>📶</span>
          <span>🔋 100%</span>
        </div>
      </div>
      
      <div style={{ flex: 1, overflow: 'auto', padding: '16px', paddingBottom: '100px' }}>
        <h1 style={{ fontSize: '24px', fontWeight: 'bold', color: '#0f172a', marginBottom: '16px' }}>Backup</h1>
        
        {/* Warning */}
        <div style={{ ...styles.card, background: '#fff7ed', marginBottom: '16px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <span style={{ fontSize: '20px' }}>⚠️</span>
            <span style={{ fontSize: '12px', color: '#9a3412' }}>
              Erstelle regelmäßig Backups. Alle Daten sind AES-256 verschlüsselt.
            </span>
          </div>
        </div>

        {/* Create Backup */}
        <div style={{ ...styles.card, marginBottom: '16px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '16px' }}>
            <div style={{ width: '48px', height: '48px', background: '#eef2ff', borderRadius: '12px', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '24px' }}>
              💾
            </div>
            <div>
              <div style={{ fontWeight: 600 }}>Neues Backup erstellen</div>
              <div style={{ fontSize: '12px', color: '#64748b' }}>Exportiert alle Daten verschlüsselt</div>
            </div>
          </div>
          <div style={{ display: 'flex', gap: '8px' }}>
            <button style={{ ...styles.button, background: '#6366f1', flex: 1 }}>
              Lokal speichern
            </button>
            <button style={{ ...styles.button, background: '#22c55e', flex: 1 }}>
              Teilen
            </button>
          </div>
        </div>

        {/* Import */}
        <div style={{ ...styles.card, marginBottom: '16px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '12px' }}>
            <div style={{ width: '48px', height: '48px', background: '#fef3c7', borderRadius: '12px', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '24px' }}>
              📥
            </div>
            <div>
              <div style={{ fontWeight: 600 }}>Backup wiederherstellen</div>
              <div style={{ fontSize: '12px', color: '#64748b' }}>Importiert ein vorhandenes Backup</div>
            </div>
          </div>
          <button style={{ ...styles.button, background: '#f97316' }}>
            Datei auswählen (.lsb)
          </button>
        </div>

        {/* Available Backups */}
        <div style={{ fontWeight: 600, marginBottom: '8px' }}>Gespeicherte Backups</div>
        {[
          { date: 'Heute 14:32', size: '24.5 MB', entries: 142 },
          { date: 'Gestern 09:15', size: '23.8 MB', entries: 140 },
          { date: '22.03.2024', size: '21.2 MB', entries: 135 },
        ].map((backup, i) => (
          <div key={i} style={{ ...styles.card, marginBottom: '8px', display: 'flex', alignItems: 'center', gap: '12px' }}>
            <div style={{ width: '44px', height: '44px', background: '#eef2ff', borderRadius: '10px', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '20px' }}>
              📦
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ fontWeight: 600 }}>{backup.date}</div>
              <div style={{ fontSize: '12px', color: '#64748b' }}>{backup.size} • {backup.entries} Einträge</div>
            </div>
            <button style={{ border: 'none', background: 'none', cursor: 'pointer', fontSize: '16px' }}>⋮</button>
          </div>
        ))}
      </div>
      
      <BottomNav />
    </div>
  );

  // Home/Journal Screen
  const HomeScreen = () => (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
      <div style={styles.statusBar}>
        <span>9:41</span>
        <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
          <span>📶</span>
          <span>🔋 100%</span>
        </div>
      </div>
      
      <div style={{ flex: 1, overflow: 'auto', padding: '16px', paddingBottom: '100px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
          <h1 style={{ fontSize: '24px', fontWeight: 'bold', color: '#0f172a' }}>Journal</h1>
          <button style={{ background: '#6366f1', border: 'none', borderRadius: '10px', padding: '8px 12px', color: 'white', fontSize: '12px', fontWeight: 500, cursor: 'pointer' }}>
            + Neu
          </button>
        </div>

        {/* Search */}
        <div style={{ ...styles.card, marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '8px' }}>
          <span>🔍</span>
          <input type="text" placeholder="Einträge durchsuchen..." style={{ border: 'none', outline: 'none', flex: 1, fontSize: '14px' }} />
        </div>

        {/* Entries */}
        {[
          { title: 'Guten Morgen!', content: 'Heute ist ein wunderbarer Tag. Die Sonne scheint...', date: 'Heute', mood: '😊', tags: ['Alltag'] },
          { title: 'Projekt-Ideen', content: 'Neue Ideen für das Journal-Projekt: KI-Assistent, Mood Tracking...', date: 'Gestern', mood: '💡', tags: ['Arbeit', 'Idee'] },
          { title: 'Wochenende', content: 'Endlich Wochenende! Pläne: Wandern, Lesen, Freunde treffen', date: '20.03', mood: '😃', tags: ['Freizeit'] },
        ].map((entry, i) => (
          <div key={i} style={{ ...styles.card, marginBottom: '12px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '8px' }}>
              <span style={{ fontSize: '24px' }}>{entry.mood}</span>
              <span style={{ flex: 1, fontWeight: 600 }}>{entry.title}</span>
              <span style={{ fontSize: '12px', color: '#64748b' }}>{entry.date}</span>
            </div>
            <div style={{ fontSize: '13px', color: '#475569', marginBottom: '8px' }}>{entry.content}</div>
            <div style={{ display: 'flex', gap: '6px' }}>
              {entry.tags.map((tag, j) => (
                <span key={j} style={{ background: '#eef2ff', color: '#4338ca', padding: '2px 8px', borderRadius: '12px', fontSize: '11px' }}>{tag}</span>
              ))}
            </div>
          </div>
        ))}
      </div>
      
      <BottomNav />
    </div>
  );

  // Settings Screen
  const SettingsScreen = () => (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
      <div style={styles.statusBar}>
        <span>9:41</span>
        <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
          <span>📶</span>
          <span>🔋 100%</span>
        </div>
      </div>
      
      <div style={{ flex: 1, overflow: 'auto', padding: '16px', paddingBottom: '100px' }}>
        <h1 style={{ fontSize: '24px', fontWeight: 'bold', color: '#0f172a', marginBottom: '16px' }}>Mehr</h1>

        {/* Sync Section */}
        <div style={{ fontSize: '12px', fontWeight: 600, color: '#64748b', marginBottom: '8px' }}>SYNCHRONISATION</div>
        {[
          { icon: '🔄', title: 'LAN Sync', desc: 'Geräte im lokalen Netzwerk synchronisieren', screen: 'sync' as Screen },
          { icon: '💾', title: 'Backup', desc: 'Lokales Backup erstellen oder importieren', screen: 'backup' as Screen },
        ].map((item, i) => (
          <div key={i} style={{ ...styles.card, marginBottom: '8px', display: 'flex', alignItems: 'center', gap: '12px', cursor: 'pointer' }}
               onClick={() => setActiveScreen(item.screen)}>
            <div style={{ width: '44px', height: '44px', background: '#f1f5f9', borderRadius: '12px', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '20px' }}>
              {item.icon}
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ fontWeight: 600 }}>{item.title}</div>
              <div style={{ fontSize: '12px', color: '#64748b' }}>{item.desc}</div>
            </div>
            <span style={{ color: '#94a3b8' }}>›</span>
          </div>
        ))}

        {/* Health Section */}
        <div style={{ fontSize: '12px', fontWeight: 600, color: '#64748b', marginTop: '16px', marginBottom: '8px' }}>GESUNDHEIT</div>
        <div style={{ ...styles.card, marginBottom: '8px', display: 'flex', alignItems: 'center', gap: '12px' }}>
          <div style={{ width: '44px', height: '44px', background: '#fef2f2', borderRadius: '12px', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '20px' }}>
            ❤️
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontWeight: 600 }}>Samsung Health</div>
            <div style={{ fontSize: '12px', color: '#64748b' }}>Gesundheitsdaten importieren</div>
          </div>
          <span style={{ color: '#94a3b8' }}>›</span>
        </div>

        {/* Integration Section */}
        <div style={{ fontSize: '12px', fontWeight: 600, color: '#64748b', marginTop: '16px', marginBottom: '8px' }}>WIDGETS & INTEGRATION</div>
        {[
          { icon: '📱', title: 'Home Screen Widgets', desc: 'Widget-Einstellungen konfigurieren' },
          { icon: '🎧', title: 'Audiobookshelf', desc: 'Hörbücher verwalten' },
        ].map((item, i) => (
          <div key={i} style={{ ...styles.card, marginBottom: '8px', display: 'flex', alignItems: 'center', gap: '12px' }}>
            <div style={{ width: '44px', height: '44px', background: '#f1f5f9', borderRadius: '12px', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '20px' }}>
              {item.icon}
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ fontWeight: 600 }}>{item.title}</div>
              <div style={{ fontSize: '12px', color: '#64748b' }}>{item.desc}</div>
            </div>
            <span style={{ color: '#94a3b8' }}>›</span>
          </div>
        ))}

        {/* App Info */}
        <div style={{ marginTop: '24px', textAlign: 'center' }}>
          <div style={{ fontSize: '20px', marginBottom: '4px' }}>📔</div>
          <div style={{ fontWeight: 600 }}>LifeSync Journal</div>
          <div style={{ fontSize: '12px', color: '#64748b' }}>Version 2.0.0</div>
          <div style={{ fontSize: '10px', color: '#94a3b8', marginTop: '4px' }}>Local-first • E2E Encrypted • Obsidian Compatible</div>
        </div>
      </div>
      
      <BottomNav />
    </div>
  );

  return (
    <div style={styles.container}>
      <div style={styles.phoneFrame}>
        <div style={styles.screen}>
          {activeScreen === 'home' && <HomeScreen />}
          {activeScreen === 'habits' && <HabitsScreen />}
          {activeScreen === 'dashboard' && <DashboardScreen />}
          {activeScreen === 'backup' && <BackupScreen />}
          {activeScreen === 'settings' && <SettingsScreen />}
          {activeScreen === 'media' && (
            <div style={{ height: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#64748b' }}>
              📷 Medien
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
