<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Menu extends Model
{
    use HasFactory;
    protected $table = 'menus';

    protected $fillable = [
        'restaurant_id',
        'name',
        'type',
        'description',
        'price',
        'image_url',
    ];

    public function restaurant()
    {
        return $this->belongsTo(Restaurant::class, 'restaurant_id', 'id');
    }
}
