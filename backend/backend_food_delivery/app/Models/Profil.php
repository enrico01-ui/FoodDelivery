<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Profil extends Model
{
    use HasFactory;
    protected $table = 'profils';
    protected $fillable = [
        'email',
        'bio',
        'image',
        'no_telp',
        'address'
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'email', 'email');
    }
}
