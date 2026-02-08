import React, { useState, useEffect, useRef } from 'react';
import { createRoot } from 'react-dom/client';
import { MapContainer, TileLayer, Marker, Popup, ZoomControl } from 'react-leaflet';
import L from 'leaflet';

// --- Fix Leaflet Default Icon Issue in React ---/
import icon from 'leaflet/dist/images/marker-icon.png';
import iconShadow from 'leaflet/dist/images/marker-shadow.png';

let DefaultIcon = L.icon({
  iconUrl: icon,
  shadowUrl: iconShadow,
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
  iconSize: [25, 41]
});

L.Marker.prototype.options.icon = DefaultIcon;

// --- Types ---

type Screen = 'home' | 'map' | 'achievements' | 'profile' | 'notifications';
type FlowState = 'idle' | 'scanning' | 'playing_ad' | 'success';

interface UserStats {
  waterSaved: number;
  level: number;
  points: number;
}

interface Notification {
  id: number;
  title: string;
  message: string;
  time: string;
  read: boolean;
  type: 'system' | 'reward' | 'info';
}

// --- Mock Data ---

const defaultCenter: [number, number] = [41.0082, 28.9784];

const otomatLocations = [
  { id: 1, lat: 41.0284, lng: 28.9736, name: 'Beyoğlu' },
  { id: 2, lat: 41.0370, lng: 28.9850, name: 'Taksim' },
  { id: 3, lat: 41.0428, lng: 29.0075, name: 'Beşiktaş' },
  { id: 4, lat: 40.9922, lng: 29.0237, name: 'Kadıköy' }
];

const mockNotifications: Notification[] = [
  { id: 1, title: 'Hoşgeldiniz!', message: 'SuVer ailesine katıldığınız için teşekkürler.', time: '2 gün önce', read: true, type: 'system' },
  { id: 2, title: 'Yeni Rozet', message: 'Bronz Damla rozetini kazandınız!', time: '1 gün önce', read: false, type: 'reward' },
  { id: 3, title: 'Güncelleme', message: 'Harita modülüne yeni otomatlar eklendi.', time: '2 saat önce', read: false, type: 'info' }
];

// --- Components ---

// 1. Navigation Bar
const BottomNav = ({ active, onNavigate, onScan }: { active: Screen, onNavigate: (s: Screen) => void, onScan: () => void }) => {
  const getButtonClass = (id: Screen) =>
    `flex flex-col items-center gap-1 transition-colors ${active === id ? 'text-primary' : 'text-slate-500 hover:text-white'}`;

  return (
    <nav className="fixed bottom-0 left-0 right-0 z-[1000] max-w-md mx-auto">
      <div className="bg-[#101c22]/90 backdrop-blur-xl border-t border-white/5 px-6 py-4 flex justify-between items-center pb-safe">
        <button onClick={() => onNavigate('home')} className={getButtonClass('home')}>
          <span className="material-symbols-outlined" style={{ fontVariationSettings: "'FILL' 1" }}>home</span>
          <span className="text-[10px] font-bold">Ana Sayfa</span>
        </button>
        <button className={getButtonClass('achievements')} onClick={() => onNavigate('achievements')}>
          <span className="material-symbols-outlined">emoji_events</span>
          <span className="text-[10px] font-bold">Başarılar</span>
        </button>

        {/* Scanner Button (Center) */}
        <div className="relative -top-5">
          <button onClick={onScan} className="flex items-center justify-center size-14 rounded-full bg-primary text-white shadow-[0_0_15px_rgba(13,162,231,0.5)] border-4 border-background-dark active:scale-95 transition-transform hover:scale-105 animate-[heartbeat_1.5s_ease-in-out_infinite]">
            <span className="material-symbols-outlined text-[28px]">qr_code_scanner</span>
          </button>
        </div>

        <button onClick={() => onNavigate('map')} className={getButtonClass('map')}>
          <span className="material-symbols-outlined">map</span>
          <span className="text-[10px] font-bold">Harita</span>
        </button>
        <button onClick={() => onNavigate('profile')} className={getButtonClass('profile')}>
          <span className="material-symbols-outlined">person</span>
          <span className="text-[10px] font-bold">Profil</span>
        </button>
      </div>
    </nav>
  );
};

// 2. Map Screen 
const MapScreen = () => {
  return (
    <div className="relative w-full h-full bg-background-dark text-white overflow-hidden">
      <MapContainer center={defaultCenter} zoom={13} style={{ width: '100%', height: '100%' }} zoomControl={false}>
        {/* Dark tiles */}
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>'
          url="https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png"
        />
        <ZoomControl position="bottomright" />

        {otomatLocations.map((loc) => (
          <Marker key={loc.id} position={[loc.lat, loc.lng]}>
            <Popup className="glass-popup">
              <div className="text-slate-900 font-bold">{loc.name}</div>
              <div className="text-slate-600 text-xs">Aktif Otomat</div>
            </Popup>
          </Marker>
        ))}
      </MapContainer>

      {/* Map Overlay Card */}
      <div className="absolute top-4 left-4 right-4 z-[400] animate-fade-in pointer-events-none">
        <div className="glass-panel p-3 rounded-xl flex items-center gap-3 shadow-lg pointer-events-auto">
          <div className="w-2 h-2 rounded-full bg-primary shadow-glow animate-pulse"></div>
          <span className="text-sm font-medium text-white/90">İstanbul'da 4 aktif otomat var.</span>
        </div>
      </div>
      <style>{`
                .leaflet-popup-content-wrapper, .leaflet-popup-tip {
                    background: rgba(255, 255, 255, 0.9);
                    backdrop-filter: blur(4px);
                }
            `}</style>
    </div>
  );
};

// 3. Home Screen with Fluid Animation
const HomeScreen = ({ onScan, onOpenNotifications, stats, fillLevel }: { onScan: () => void, onOpenNotifications: () => void, stats: UserStats, fillLevel: number }) => {
  const [countdown, setCountdown] = useState(120); // 2 minutes countdown

  useEffect(() => {
    const timer = setInterval(() => {
      setCountdown((prev) => (prev > 0 ? prev - 1 : 0));
    }, 1000);
    return () => clearInterval(timer);
  }, []);

  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };
  return (
    <div className="relative flex h-full flex-col shadow-2xl overflow-hidden bg-background-dark pb-24 overflow-y-auto hide-scrollbar">
      {/* Ambient Background Glows */}
      <div className="absolute top-[-10%] left-[-10%] w-[50%] h-[30%] bg-primary/20 rounded-full blur-[100px] pointer-events-none"></div>
      <div className="absolute bottom-[-10%] right-[-10%] w-[60%] h-[40%] bg-primary/10 rounded-full blur-[120px] pointer-events-none"></div>

      {/* Header */}
      <header className="relative z-20 flex items-center justify-between p-6 pb-2">
        <button className="flex items-center justify-center p-2 rounded-full hover:bg-white/5 transition-colors text-white/80">
          <span className="material-symbols-outlined" style={{ fontSize: '28px' }}>menu</span>
        </button>
        <div className="flex items-center gap-2">
          <span className="material-symbols-outlined text-primary" style={{ fontSize: '24px' }}>water_drop</span>
          <h1 className="text-xl font-bold tracking-tight">SuVer</h1>
        </div>
        <button
          onClick={onOpenNotifications}
          className="relative flex items-center justify-center p-2 rounded-full hover:bg-white/5 transition-colors text-white/80"
        >
          <span className="material-symbols-outlined" style={{ fontSize: '28px' }}>notifications</span>
          <span className="absolute top-2 right-2 w-2 h-2 bg-primary rounded-full shadow-glow-sm"></span>
        </button>
      </header>

      {/* Progress Section */}
      <section className="relative z-10 px-6 py-4 mt-2">
        <div className="glass-panel rounded-2xl p-5">
          <div className="flex justify-between items-end mb-3">
            <div>
              <p className="text-xs text-white/60 font-medium uppercase tracking-wider mb-1">Günlük Su Hakkı</p>
              <p className="text-2xl font-bold text-white">330<span className="text-sm text-primary font-normal ml-1">ml</span></p>
            </div>
            <div className="text-right">
              <p className="text-sm font-medium text-primary">66%</p>
            </div>
          </div>
          <div className="relative w-full h-2 bg-white/10 rounded-full overflow-hidden">
            <div className="absolute top-0 left-0 h-full bg-primary rounded-full transition-all duration-1000 ease-out shadow-glow" style={{ width: '66%' }}></div>
          </div>
          <div className="flex justify-between items-center mt-3">
            <p className="text-xs text-white/40">2/3 Reklam İzledi</p>
            <div className="flex items-center gap-1 text-xs text-primary/80">
              <span className="material-symbols-outlined" style={{ fontSize: '14px' }}>bolt</span>
              <span>+1 Hak Mevcut</span>
            </div>
          </div>
        </div>
      </section>

      {/* Main Action Area (Center) - FLUID ANIMATION ADDED */}
      <main className="flex-1 flex flex-col items-center justify-center relative z-10 py-8 min-h-[300px]">
        {/* Glow behind button */}
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-48 h-48 bg-primary/20 rounded-full blur-[60px] pointer-events-none animate-pulse"></div>

        {/* Glass Button with Liquid Effect */}
        <button
          onClick={onScan}
          className="group relative w-56 h-56 rounded-full glass-button flex flex-col items-center justify-center transition-all duration-300 hover:scale-105 hover:border-primary/50 hover:shadow-glow active:scale-95 cursor-pointer overflow-hidden"
        >
          {/* Liquid Container */}
          <div className="liquid-container">
            <div className="wave wave-1" style={{ top: `${100 - fillLevel}%` }}></div>
            <div className="wave wave-2" style={{ top: `${100 - fillLevel}%` }}></div>
            <div className="wave wave-3" style={{ top: `${100 - fillLevel}%` }}></div>
          </div>

          <div className="absolute inset-0 rounded-full bg-gradient-to-b from-white/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500 z-10"></div>
          <span className="material-symbols-outlined text-white mb-3 group-hover:text-white transition-colors duration-300 relative z-20" style={{ fontSize: '48px', fontVariationSettings: "'FILL' 1" }}>play_circle</span>
          <span className="text-3xl font-bold text-white tracking-widest neon-text group-hover:scale-110 transition-transform duration-300 relative z-20 drop-shadow-[0_2px_4px_rgba(0,0,0,0.8)]">SU AL</span>
          <span className="text-[11px] text-white/70 tracking-[0.15em] uppercase mt-2 group-hover:text-white/90 transition-colors relative z-20 drop-shadow-[0_1px_2px_rgba(0,0,0,0.8)]">Reklam İzle</span>
        </button>

        {/* Countdown Timer */}
        <div className="mt-6 glass-panel px-6 py-3 rounded-full flex items-center gap-2">
          <span className="material-symbols-outlined text-primary text-lg">schedule</span>
          <span className="text-sm text-white/80">Sonraki su hakkı:</span>
          <span className="text-lg font-bold text-primary">{formatTime(countdown)}</span>
        </div>

        {/* Slogan */}
        <div className="mt-12 text-center space-y-2">
          <h2 className="text-2xl md:text-3xl font-light text-white tracking-[0.15em] leading-tight">
            HER DAMLA <br />
            <span className="font-bold text-transparent bg-clip-text bg-gradient-to-r from-primary to-white">DEĞERLİ</span>
          </h2>
          <p className="text-white/40 text-xs tracking-widest uppercase">Gelecek için biriktir</p>
        </div>
      </main>

      {/* Sponsors Section */}
      <section className="relative z-10 px-8 pb-4">
        <div className="border-t border-white/5 pt-6">
          <p className="text-[10px] text-center text-white/30 uppercase tracking-[0.2em] mb-4">Katkılarıyla</p>
          <div className="flex justify-center items-center gap-8 grayscale opacity-40 hover:opacity-80 transition-opacity duration-300">
            {/* Sponsor Logos */}
            <div className="flex items-center gap-2">
              <span className="material-symbols-outlined">apartment</span>
              <span className="font-bold text-sm">BB</span>
            </div>
            <div className="h-4 w-px bg-white/20"></div>
            <div className="flex items-center gap-2">
              <span className="material-symbols-outlined">water_drop</span>
              <span className="font-bold text-sm">PURE</span>
            </div>
            <div className="h-4 w-px bg-white/20"></div>
            <div className="flex items-center gap-2">
              <span className="material-symbols-outlined">recycling</span>
              <span className="font-bold text-sm">ECO</span>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
};

// 4. Achievements Screen
const AchievementsScreen = () => {
  const badges = [
    { id: 1, name: 'İlk Damla', icon: 'water_drop', color: 'text-blue-400', unlocked: true, description: 'İlk suyunuzu aldınız' },
    { id: 2, name: 'Çevre Dostu', icon: 'eco', color: 'text-green-400', unlocked: true, description: '10 plastik şişe tasarrufu' },
    { id: 3, name: 'Sadık Kullanıcı', icon: 'loyalty', color: 'text-purple-400', unlocked: true, description: '7 gün üst üste kullanım' },
    { id: 4, name: 'Su Elçisi', icon: 'campaign', color: 'text-yellow-400', unlocked: false, description: '3 arkadaş davet edin' },
    { id: 5, name: 'Tasarruf Şampiyonu', icon: 'emoji_events', color: 'text-orange-400', unlocked: false, description: '100 litre tasarruf' },
    { id: 6, name: 'Harita Kaşifi', icon: 'explore', color: 'text-cyan-400', unlocked: true, description: '5 farklı otomat kullanın' },
  ];

  const achievements = [
    { id: 1, title: 'Bronz Damla Rozeti', desc: 'İlk 50 litre tasarruf', date: '2 gün önce', icon: 'military_tech', color: 'text-amber-600' },
    { id: 2, title: 'Haftalık Hedef', desc: '7 günlük seri tamamlandı', date: '1 gün önce', icon: 'calendar_today', color: 'text-primary' },
    { id: 3, title: 'Yeni Seviye!', desc: 'Seviye 3\'e ulaştınız', date: '3 saat önce', icon: 'trending_up', color: 'text-green-400' },
  ];

  return (
    <div className="flex-1 flex flex-col pb-24 mx-auto w-full h-full overflow-y-auto hide-scrollbar bg-background-dark">
      {/* Top AppBar */}
      <div className="sticky top-0 z-50 bg-background-dark/95 backdrop-blur-md border-b border-white/5">
        <div className="flex items-center p-4 pb-2 justify-between">
          <button className="text-white flex size-12 shrink-0 items-center justify-center rounded-full hover:bg-white/10 transition-colors">
            <span className="material-symbols-outlined">arrow_back</span>
          </button>
          <h2 className="text-white text-lg font-bold leading-tight tracking-[-0.015em] flex-1 text-center">Başarılar</h2>
          <div className="flex w-12 items-center justify-end">
            <button className="flex size-12 shrink-0 items-center justify-center rounded-full hover:bg-white/10 transition-colors">
              <span className="material-symbols-outlined">more_horiz</span>
            </button>
          </div>
        </div>
      </div>

      {/* Stats Section */}
      <div className="p-4">
        <div className="grid grid-cols-2 gap-3">
          <div className="flex flex-col gap-1 rounded-xl p-4 bg-surface-dark border border-white/5 shadow-lg relative overflow-hidden group">
            <div className="absolute top-0 right-0 w-16 h-16 bg-primary/10 rounded-full blur-xl -mr-8 -mt-8"></div>
            <div className="flex items-center gap-2 mb-1">
              <span className="material-symbols-outlined text-primary text-[20px]">account_balance_wallet</span>
              <p className="text-slate-400 text-xs font-medium uppercase tracking-wider">Tasarruf</p>
            </div>
            <p className="text-white text-2xl font-bold leading-tight group-hover:text-primary transition-colors">150 TL</p>
          </div>
          <div className="flex flex-col gap-1 rounded-xl p-4 bg-surface-dark border border-white/5 shadow-lg relative overflow-hidden group">
            <div className="absolute top-0 right-0 w-16 h-16 bg-emerald-500/10 rounded-full blur-xl -mr-8 -mt-8"></div>
            <div className="flex items-center gap-2 mb-1">
              <span className="material-symbols-outlined text-emerald-400 text-[20px]">water_drop</span>
              <p className="text-slate-400 text-xs font-medium uppercase tracking-wider">Doğa</p>
            </div>
            <p className="text-white text-2xl font-bold leading-tight group-hover:text-emerald-400 transition-colors">500 LT</p>
          </div>
          <div className="col-span-2 flex flex-col gap-1 rounded-xl p-4 bg-surface-dark border border-white/5 shadow-lg relative overflow-hidden group">
            <div className="absolute top-0 right-0 w-16 h-16 bg-purple-500/10 rounded-full blur-xl -mr-8 -mt-8"></div>
            <div className="flex items-center gap-2 mb-1">
              <span className="material-symbols-outlined text-purple-400 text-[20px]">military_tech</span>
              <p className="text-slate-400 text-xs font-medium uppercase tracking-wider">Elçi</p>
            </div>
            <p className="text-white text-2xl font-bold leading-tight group-hover:text-purple-400 transition-colors">Seviye 3</p>
          </div>
        </div>
      </div>

      {/* Badges Section */}
      <div className="px-4 pt-6 pb-2">
        <h3 className="text-white text-lg font-bold leading-tight tracking-[-0.015em]">Rozetler</h3>
        <p className="text-slate-400 text-sm mt-1">Kazandığınız başarılar</p>
      </div>

      <div className="px-4 pb-6">
        <div className="grid grid-cols-3 gap-3">
          {badges.map((badge) => (
            <div
              key={badge.id}
              className={`flex flex-col items-center gap-2 rounded-xl p-4 border transition-all ${badge.unlocked
                ? 'bg-surface-dark border-white/10 shadow-lg'
                : 'bg-surface-dark/30 border-white/5 opacity-40'
                }`}
            >
              <div className={`flex items-center justify-center size-12 rounded-full ${badge.unlocked ? 'bg-white/5' : 'bg-white/5'}`}>
                <span className={`material-symbols-outlined ${badge.unlocked ? badge.color : 'text-slate-600'} text-[28px]`}>
                  {badge.icon}
                </span>
              </div>
              <p className={`text-xs text-center font-medium ${badge.unlocked ? 'text-white' : 'text-slate-600'}`}>
                {badge.name}
              </p>
              {badge.unlocked && (
                <span className="material-symbols-outlined text-green-400 text-[16px]">check_circle</span>
              )}
            </div>
          ))}
        </div>
      </div>

      {/* Recent Achievements */}
      <div className="px-4 pt-2 pb-2">
        <h3 className="text-white text-lg font-bold leading-tight tracking-[-0.015em]">Son Başarılar</h3>
      </div>

      <div className="px-4 pb-6 space-y-3">
        {achievements.map((achievement) => (
          <div key={achievement.id} className="glass-panel rounded-xl p-4 flex items-start gap-3">
            <div className={`flex items-center justify-center size-12 rounded-full bg-white/5 shrink-0`}>
              <span className={`material-symbols-outlined ${achievement.color} text-[24px]`}>{achievement.icon}</span>
            </div>
            <div className="flex-1">
              <h4 className="text-white font-bold text-sm">{achievement.title}</h4>
              <p className="text-slate-400 text-xs mt-1">{achievement.desc}</p>
              <p className="text-slate-500 text-[10px] mt-2">{achievement.date}</p>
            </div>
          </div>
        ))}
      </div>

      <div className="px-4">
        <div className="grid grid-cols-[48px_1fr] gap-x-0 relative">
          <div className="absolute left-[23px] top-4 bottom-8 w-[2px] bg-white/10 h-full z-0"></div>
          {/* Items omitted for brevity, same as previous */}
          <div className="flex flex-col items-center pt-1 relative z-10">
            <div className="flex items-center justify-center size-12 rounded-full bg-surface-dark border-2 border-primary shadow-[0_0_10px_rgba(13,162,231,0.3)]">
              <span className="material-symbols-outlined text-primary">check</span>
            </div>
            <div className="w-[2px] bg-primary h-full my-2"></div>
          </div>
          <div className="flex flex-col py-1 pl-4 pb-8">
            <div className="flex items-center gap-2">
              <p className="text-white text-base font-bold">SuVer Ailesine Katılım</p>
            </div>
            <p className="text-slate-400 text-sm mt-1">Hoşgeldiniz! İlk adım tamamlandı.</p>
          </div>
        </div>
      </div>
    </div>
  );
}

// 5. Notifications Screen
const NotificationsScreen = ({ onBack }: { onBack: () => void }) => {
  return (
    <div className="flex-1 flex flex-col pb-24 mx-auto w-full h-full overflow-y-auto hide-scrollbar bg-background-dark">
      <div className="sticky top-0 z-50 bg-background-dark/95 backdrop-blur-md border-b border-white/5">
        <div className="flex items-center p-4 pb-2 justify-between">
          <button onClick={onBack} className="text-white flex size-12 shrink-0 items-center justify-center rounded-full hover:bg-white/10 transition-colors">
            <span className="material-symbols-outlined">arrow_back</span>
          </button>
          <h2 className="text-white text-lg font-bold leading-tight flex-1 text-center">Bildirimler</h2>
          <div className="w-12"></div>
        </div>
      </div>

      <div className="p-4 space-y-3">
        {mockNotifications.map((notif) => (
          <div key={notif.id} className={`glass-panel p-4 rounded-xl flex gap-3 ${notif.read ? 'opacity-70' : ''} active:scale-98 transition-transform`}>
            <div className={`size-10 rounded-full flex items-center justify-center shrink-0 ${notif.type === 'reward' ? 'bg-yellow-500/20 text-yellow-500' :
              notif.type === 'info' ? 'bg-blue-500/20 text-blue-500' :
                'bg-white/10 text-white'
              }`}>
              <span className="material-symbols-outlined">
                {notif.type === 'reward' ? 'emoji_events' : notif.type === 'info' ? 'info' : 'notifications'}
              </span>
            </div>
            <div className="flex-1">
              <div className="flex justify-between items-start mb-1">
                <h3 className="font-bold text-white text-sm">{notif.title}</h3>
                <span className="text-[10px] text-slate-500">{notif.time}</span>
              </div>
              <p className="text-xs text-slate-400 leading-relaxed">{notif.message}</p>
            </div>
            {!notif.read && <div className="w-2 h-2 rounded-full bg-primary mt-2"></div>}
          </div>
        ))}
      </div>
    </div>
  );
};

// 6. Profile Screen
const ProfileScreen = ({ stats, onOpenNotifications }: { stats: UserStats, onOpenNotifications: () => void }) => {
  const menuItems = [
    { id: 1, icon: 'person', title: 'Hesap Bilgileri', desc: 'Profil ve kişisel bilgiler', color: 'text-blue-400' },
    { id: 2, icon: 'notifications', title: 'Bildirimler', desc: 'Uygulama bildirim ayarları', color: 'text-yellow-400', action: onOpenNotifications },
    { id: 3, icon: 'credit_card', title: 'Ödeme Yöntemleri', desc: 'Kayıtlı kartlar ve cüzdan', color: 'text-green-400' },
    { id: 4, icon: 'language', title: 'Dil Seçimi', desc: 'Türkçe', color: 'text-purple-400' },
    { id: 5, icon: 'help', title: 'Yardım & Destek', desc: 'SSS ve iletişim', color: 'text-orange-400' },
    { id: 6, icon: 'policy', title: 'Gizlilik Politikası', desc: 'Kullanım koşulları', color: 'text-cyan-400' },
  ];

  return (
    <div className="flex-1 flex flex-col pb-24 mx-auto w-full h-full overflow-y-auto hide-scrollbar bg-background-dark">
      {/* Header with gradient */}
      <div className="relative pt-10 pb-6 flex flex-col items-center">
        <div className="absolute top-0 inset-x-0 h-32 bg-gradient-to-b from-primary/20 to-transparent pointer-events-none"></div>

        {/* Avatar */}
        <div className="relative">
          <div className="w-24 h-24 rounded-full border-4 border-background-dark bg-surface-highlight flex items-center justify-center relative z-10 shadow-xl">
            <span className="material-symbols-outlined text-4xl text-white/50">person</span>
          </div>
          <div className="absolute bottom-0 right-0 w-8 h-8 bg-primary rounded-full flex items-center justify-center border-4 border-background-dark z-20 cursor-pointer hover:scale-110 transition-transform">
            <span className="material-symbols-outlined text-xs text-white">edit</span>
          </div>
        </div>

        {/* User Info */}
        <h2 className="text-xl font-bold text-white mt-3">Ahmet Yılmaz</h2>
        <p className="text-primary text-sm font-medium">@ahmetyilmaz</p>
        <p className="text-slate-400 text-xs mt-1">Üyelik: 15 Ocak 2026</p>
      </div>

      {/* Stats Panel */}
      <div className="px-6 mb-6">
        <div className="glass-panel p-4 rounded-xl flex justify-between divide-x divide-white/10">
          <div className="flex-1 text-center">
            <div className="text-lg font-bold text-white">{stats.waterSaved.toFixed(1)}L</div>
            <div className="text-[10px] uppercase tracking-wider text-slate-400">Su Tasarrufu</div>
          </div>
          <div className="flex-1 text-center">
            <div className="text-lg font-bold text-white">Level {stats.level}</div>
            <div className="text-[10px] uppercase tracking-wider text-slate-400">Üyelik</div>
          </div>
          <div className="flex-1 text-center">
            <div className="text-lg font-bold text-white">{stats.points}</div>
            <div className="text-[10px] uppercase tracking-wider text-slate-400">Puan</div>
          </div>
        </div>
      </div>

      {/* Achievements Preview */}
      <div className="px-6 mb-4">
        <div className="flex items-center justify-between mb-3">
          <h3 className="text-white font-bold text-sm">Son Rozetler</h3>
          <button className="text-primary text-xs font-medium">Tümünü Gör</button>
        </div>
        <div className="flex gap-2">
          <div className="flex-1 glass-panel p-3 rounded-xl flex flex-col items-center">
            <span className="material-symbols-outlined text-blue-400 text-2xl">water_drop</span>
            <p className="text-[10px] text-white mt-1 text-center">İlk Damla</p>
          </div>
          <div className="flex-1 glass-panel p-3 rounded-xl flex flex-col items-center">
            <span className="material-symbols-outlined text-green-400 text-2xl">eco</span>
            <p className="text-[10px] text-white mt-1 text-center">Çevre Dostu</p>
          </div>
          <div className="flex-1 glass-panel p-3 rounded-xl flex flex-col items-center">
            <span className="material-symbols-outlined text-purple-400 text-2xl">loyalty</span>
            <p className="text-[10px] text-white mt-1 text-center">Sadık</p>
          </div>
        </div>
      </div>

      {/* Settings Section */}
      <div className="px-6 mb-4">
        <h3 className="text-white font-bold text-sm mb-3">Ayarlar</h3>
      </div>

      <div className="px-4 space-y-2 pb-6">
        {menuItems.map((item) => (
          <button
            key={item.id}
            onClick={item.action}
            className="w-full glass-panel p-4 rounded-xl flex items-center justify-between group hover:bg-white/5 active:scale-98 transition-all"
          >
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-full bg-surface-highlight flex items-center justify-center">
                <span className={`material-symbols-outlined ${item.color} text-xl`}>{item.icon}</span>
              </div>
              <div className="text-left">
                <div className="text-white font-medium text-sm">{item.title}</div>
                <div className="text-xs text-slate-400">{item.desc}</div>
              </div>
            </div>
            <span className="material-symbols-outlined text-slate-500 group-hover:text-white transition-colors">chevron_right</span>
          </button>
        ))}
      </div>

      {/* Logout Button */}
      <div className="px-6 pb-8">
        <button className="w-full glass-panel p-4 rounded-xl flex items-center justify-center gap-2 border border-red-500/20 hover:bg-red-500/10 active:scale-98 transition-all">
          <span className="material-symbols-outlined text-red-400">logout</span>
          <span className="text-red-400 font-bold">Çıkış Yap</span>
        </button>
      </div>
    </div>
  );
};

// 7. Overlays (Ad & Success)
const AdOverlay = ({ onComplete }: { onComplete: () => void }) => {
  const [timeLeft, setTimeLeft] = useState(15);
  const videoRef = useRef<HTMLVideoElement>(null);

  // Random video selection
  const adVideos = [
    '/ads/BeyogluOtomatAds.mp4',
    '/ads/SuVerAdsmascot.mp4'
  ];
  const [selectedVideo] = useState(adVideos[Math.floor(Math.random() * adVideos.length)]);

  useEffect(() => {
    const timer = setInterval(() => {
      setTimeLeft((prev) => {
        if (prev <= 1) {
          clearInterval(timer);
          onComplete();
          return 0;
        }
        return prev - 1;
      });
    }, 1000);
    return () => clearInterval(timer);
  }, [onComplete]);

  return (
    <div className="fixed inset-0 bg-black z-[2000] flex flex-col">
      <div className="absolute top-4 right-4 bg-black/50 backdrop-blur px-3 py-1 rounded-full text-white text-xs border border-white/10 z-20">
        Sponsor Reklamı • {timeLeft}s
      </div>

      <div className="flex-1 flex flex-col items-center justify-center relative">
        {/* Video Player - Falls back to mock if video not found */}
        <video
          ref={videoRef}
          className="absolute inset-0 w-full h-full object-cover"
          autoPlay
          muted
          playsInline
          onError={() => {
            // Fallback to mock content if video fails to load
            if (videoRef.current) {
              videoRef.current.style.display = 'none';
            }
          }}
        >
          <source src={selectedVideo} type="video/mp4" />
        </video>

        {/* Mock Content (fallback) */}
        <div className="absolute inset-0 bg-gradient-to-br from-indigo-900 via-purple-900 to-black animate-pulse opacity-50"></div>
        <span className="material-symbols-outlined text-6xl text-white/50 mb-4 z-10">play_circle</span>
        <p className="text-white z-10 font-bold">Harika Su Markası</p>
        <p className="text-white/50 text-sm z-10">Dünyanın en saf suyu...</p>

        {/* Progress Bar */}
        <div className="absolute bottom-0 left-0 h-1 bg-primary transition-all duration-1000 ease-linear z-30" style={{ width: `${((15 - timeLeft) / 15) * 100}%` }}></div>
      </div>

      <div className="p-8 bg-black/90 text-center">
        <h3 className="text-white font-bold mb-2">SuVer ile Kazanın</h3>
        <p className="text-xs text-slate-400">Reklam bitiminde suyunuz otomatik olarak verilecektir.</p>
      </div>
    </div>
  );
};

const SuccessOverlay = ({ onDismiss }: { onDismiss: () => void }) => {
  useEffect(() => {
    const timer = setTimeout(onDismiss, 3000);
    return () => clearTimeout(timer);
  }, [onDismiss]);

  return (
    <div className="fixed inset-0 bg-primary/90 backdrop-blur-xl z-[2000] flex flex-col items-center justify-center p-8 text-center animate-fade-in">
      <div className="size-24 bg-white rounded-full flex items-center justify-center mb-6 shadow-2xl animate-[bounce_1s_infinite]">
        <span className="material-symbols-outlined text-5xl text-primary">water_drop</span>
      </div>
      <h2 className="text-3xl font-bold text-white mb-2">Su Hazırlanıyor!</h2>
      <p className="text-white/80 text-lg">Afiyet Olsun.</p>
      <p className="text-white/60 text-sm mt-8">+10 Puan & 330ml Eklendi</p>
    </div>
  );
};

// --- Main App Component ---

const App = () => {
  const [activeScreen, setActiveScreen] = useState<Screen>('home');
  const [flowState, setFlowState] = useState<FlowState>('idle');
  const [fillLevel, setFillLevel] = useState(10); // Start at 10%
  const [stats, setStats] = useState<UserStats>({
    waterSaved: 12.5,
    level: 3,
    points: 85
  });

  // Scanner Mock
  useEffect(() => {
    if (flowState === 'scanning') {
      const timer = setTimeout(() => {
        setFlowState('playing_ad');
      }, 3000);
      return () => clearTimeout(timer);
    }
  }, [flowState]);

  // Handlers
  const handleScanComplete = () => {
    setFlowState('success');
    setFillLevel(70); // Update to 70% on success
    setStats(prev => ({
      waterSaved: prev.waterSaved + 0.33,
      level: prev.level,
      points: prev.points + 10
    }));
  };

  const handleSuccessDismiss = () => {
    setFlowState('idle');
    setActiveScreen('home');
    // Optional: Reset fill level after delay or keep it? 
    // For demo purposes, let's keep it at 70 to show the effect, 
    // but maybe reset if they start scanning again? 
    // Let's reset it here so they can see the animation again next time they scan.
    setTimeout(() => setFillLevel(10), 500);
  };

  // Render Scanner Overlay
  const renderScanner = () => (
    <div className="fixed inset-0 bg-black z-[2000] flex flex-col items-center justify-center">
      <div className="absolute top-0 left-0 right-0 p-4 bg-gradient-to-b from-black/80 to-transparent z-10 flex justify-between">
        <h2 className="text-white font-bold text-lg">QR Tara</h2>
        <button onClick={() => setFlowState('idle')} className="text-white">
          <span className="material-symbols-outlined">close</span>
        </button>
      </div>
      <div className="relative w-full h-full">
        <div className="absolute inset-0 bg-slate-900 opacity-50"></div>
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-64 h-64 border-2 border-primary rounded-2xl shadow-[0_0_0_9999px_rgba(0,0,0,0.8)] z-20">
          <div className="w-full h-1 bg-primary shadow-[0_0_20px_#0da2e7] animate-[scan_2s_infinite]"></div>
        </div>
        <div className="absolute bottom-20 left-0 right-0 text-center text-white z-20">
          <p>Otomat üzerindeki kodu okutun</p>
        </div>
      </div>
    </div>
  );

  return (
    <div className="app-container h-screen bg-background-dark w-full overflow-hidden font-body text-white">
      {/* Flow Overlays */}
      {flowState === 'scanning' && renderScanner()}
      {flowState === 'playing_ad' && <AdOverlay onComplete={handleScanComplete} />}
      {flowState === 'success' && <SuccessOverlay onDismiss={handleSuccessDismiss} />}

      {/* Main Content Area */}
      <div className="h-full pb-[10px]">
        {activeScreen === 'home' && <HomeScreen onScan={() => setFlowState('scanning')} onOpenNotifications={() => setActiveScreen('notifications')} stats={stats} fillLevel={fillLevel} />}
        {activeScreen === 'achievements' && <AchievementsScreen />}
        {activeScreen === 'map' && <MapScreen />}
        {activeScreen === 'profile' && <ProfileScreen stats={stats} onOpenNotifications={() => setActiveScreen('notifications')} />}
        {activeScreen === 'notifications' && <NotificationsScreen onBack={() => setActiveScreen('home')} />}
      </div>

      {/* Hide Nav if full screen flow or notifications? Maybe keep for notifications only. */}
      {flowState === 'idle' && (
        <BottomNav
          active={activeScreen}
          onNavigate={setActiveScreen}
          onScan={() => setFlowState('scanning')}
        />
      )}
    </div>
  );
};

// Mount
const container = document.getElementById('root');
if (container) {
  const root = createRoot(container);
  root.render(<App />);
}
